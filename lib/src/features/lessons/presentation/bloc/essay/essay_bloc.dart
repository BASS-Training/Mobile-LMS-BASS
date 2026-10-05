import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/essay_question_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';
import '../../../domain/repositories/essay_repository.dart';
import '../../../domain/usecases/submit_essay_usecase.dart';
import 'essay_event.dart';
import 'essay_state.dart';

class EssayBloc extends Bloc<EssayEvent, EssayState> {
  static const autosaveDelay = Duration(milliseconds: 700);

  final EssayRepository repository;
  final SubmitEssayUseCase submitUseCase;
  final LessonResultRepository? resultRepository;
  final GetCurrentUserUseCase? getCurrentUserUseCase;
  String _courseId = '';
  String _courseTitle = '';
  String _lessonTitle = '';
  Timer? _autosaveTimer;
  _EssayDraftSnapshot? _pendingAutosave;
  _EssayDraftSnapshot? _inFlightAutosave;
  _EssayDraftSnapshot? _lastSyncedAutosave;
  Future<void>? _autosaveDrain;

  EssayBloc({
    required this.repository,
    required this.submitUseCase,
    this.resultRepository,
    this.getCurrentUserUseCase,
  }) : super(const EssayState()) {
    on<LoadEssay>((event, emit) async {
      _courseId = event.courseId;
      _courseTitle = event.courseTitle;
      _lessonTitle = event.lessonTitle;

      final questions = await repository.getQuestions(
        event.lessonId,
        event.content,
      );
      final drafts = await repository.getDraftAnswers(
        event.lessonId,
        questions,
      );

      emit(
        state.copyWith(
          lessonId: event.lessonId,
          questions: questions,
          workingAnswers: Map.from(drafts),
          savedDraftAnswers: Map.from(drafts),
          currentQuestionIndex: 0,
          isLoading: false,
          isSubmitted: LocalStorage.isEssaySubmitted(event.lessonId),
        ),
      );
    });

    on<AnswerChanged>((event, emit) {
      if (state.isSubmitting || state.isSubmitted) return;

      final newWorkingAnswers = Map<int, String>.from(state.workingAnswers);
      newWorkingAnswers[event.questionIndex] = event.answer;
      emit(state.copyWith(workingAnswers: newWorkingAnswers));
      _scheduleAutosave(newWorkingAnswers);
    });

    on<ChangeQuestion>((event, emit) async {
      if (state.isSubmitting || state.isSubmitted) return;

      // Auto-save draft local memory saat pindah soal
      final currentQuestionIndex = state.currentQuestionIndex;
      final currentAnswer = state.workingAnswers[currentQuestionIndex] ?? '';
      await repository.saveDraftAnswer(
        state.lessonId,
        currentQuestionIndex,
        currentAnswer,
      );

      final newSavedDrafts = Map<int, String>.from(state.savedDraftAnswers);
      newSavedDrafts[currentQuestionIndex] = currentAnswer;

      emit(
        state.copyWith(
          currentQuestionIndex: event.index,
          savedDraftAnswers: newSavedDrafts,
        ),
      );
      _queueAutosave(state.workingAnswers);
      await _flushAutosave();
    });

    on<SaveDraftClicked>((event, emit) async {
      if (state.isSubmitting || state.isSubmitted) return;

      final currentQuestionIndex = state.currentQuestionIndex;
      final currentAnswer = state.workingAnswers[currentQuestionIndex] ?? '';
      await repository.saveDraftAnswer(
        state.lessonId,
        currentQuestionIndex,
        currentAnswer,
      );

      final newSavedDrafts = Map<int, String>.from(state.savedDraftAnswers);
      newSavedDrafts[currentQuestionIndex] = currentAnswer;

      _queueAutosave(state.workingAnswers);
      await _flushAutosave();

      emit(
        state.copyWith(
          currentQuestionIndex:
              event.nextQuestionIndex ?? state.currentQuestionIndex,
          savedDraftAnswers: newSavedDrafts,
          snackbarMessage: 'Draft jawaban disimpan.',
        ),
      );
    });

    on<SubmitEssayClicked>((event, emit) async {
      if (state.isSubmitting || state.isSubmitted) return;
      emit(state.copyWith(isSubmitting: true));

      _queueAutosave(state.workingAnswers);
      await _flushAutosave();

      final currentUser = getCurrentUserUseCase != null
          ? await getCurrentUserUseCase!().catchError((_) => null)
          : null;

      if (currentUser == null || currentUser.email.trim().isEmpty) {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage:
                'Akun belum terhubung ke email backend, jadi jawaban essay belum bisa dikirim ke database.',
          ),
        );
        return;
      }

      final isSuccess = await submitUseCase.execute(
        state.lessonId,
        state.questions,
        state.workingAnswers,
        state.totalQuestions,
        userEmail: currentUser.email,
      );

      if (isSuccess) {
        dynamic savedAttempt;
        if (resultRepository != null) {
          try {
            final questions = state.questions.asMap().entries.map((entry) {
              final answer = state.workingAnswers[entry.key] ?? '';
              return LessonAttemptQuestionSnapshot(
                questionIndex: entry.key,
                questionText: entry.value.text,
                options: const [],
                writtenAnswer: answer,
              );
            }).toList();

            savedAttempt = await resultRepository!.recordEssaySubmission(
              courseId: _courseId,
              courseTitle: _courseTitle,
              lessonId: state.lessonId,
              lessonTitle: _lessonTitle,
              questions: questions,
            );
          } catch (_) {
            // Keep essay submit flow intact if history save fails.
          }
        }

        emit(
          state.copyWith(
            isSubmitting: false,
            isSuccess: true,
            savedDraftAnswers: Map.from(state.workingAnswers),
            isSubmitted: true,
            lastAttempt: savedAttempt,
          ),
        );
        await LocalStorage.markEssaySubmitted(state.lessonId);
      } else {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage:
                'Masih ada nomor yang belum memenuhi minimal ${SubmitEssayUseCase.minWordsPerQuestion} kata.',
          ),
        );
      }
    });

    on<ClearSnackbarMessage>((event, emit) {
      emit(state.copyWith(snackbarMessage: null, errorMessage: null));
    });
  }

  void _scheduleAutosave(Map<int, String> answers) {
    _queueAutosave(answers);
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(autosaveDelay, () {
      unawaited(_flushAutosave());
    });
  }

  void _queueAutosave(Map<int, String> answers) {
    if (state.lessonId.isEmpty || state.questions.isEmpty) return;
    final snapshot = _EssayDraftSnapshot(
      lessonId: state.lessonId,
      questions: List.unmodifiable(state.questions),
      answers: Map.unmodifiable(answers),
    );
    if (snapshot.hasSameAnswers(_pendingAutosave)) {
      return;
    }
    if (snapshot.hasSameAnswers(_inFlightAutosave) ||
        (_inFlightAutosave == null &&
            snapshot.hasSameAnswers(_lastSyncedAutosave))) {
      _pendingAutosave = null;
      return;
    }
    _pendingAutosave = snapshot;
  }

  Future<void> _flushAutosave() async {
    _autosaveTimer?.cancel();
    _autosaveTimer = null;

    while (_pendingAutosave != null || _autosaveDrain != null) {
      final activeDrain = _autosaveDrain;
      if (activeDrain != null) {
        await activeDrain;
        continue;
      }

      final drain = _drainAutosaves();
      _autosaveDrain = drain;
      try {
        await drain;
      } finally {
        if (identical(_autosaveDrain, drain)) {
          _autosaveDrain = null;
        }
      }
    }
  }

  Future<void> _drainAutosaves() async {
    while (_pendingAutosave != null) {
      final snapshot = _pendingAutosave!;
      _pendingAutosave = null;
      _inFlightAutosave = snapshot;
      try {
        await repository.syncDraftAnswers(
          snapshot.lessonId,
          snapshot.questions,
          snapshot.answers,
        );
        _lastSyncedAutosave = snapshot;
      } catch (_) {
        // Autosave is best-effort; explicit submit still reports its own error.
      } finally {
        _inFlightAutosave = null;
      }
    }
  }

  @override
  Future<void> close() async {
    _autosaveTimer?.cancel();
    if (state.lessonId.isNotEmpty && state.questions.isNotEmpty) {
      final currentAnswer =
          state.workingAnswers[state.currentQuestionIndex] ?? '';
      try {
        await repository.saveDraftAnswer(
          state.lessonId,
          state.currentQuestionIndex,
          currentAnswer,
        );
      } catch (_) {
        // Closing the page must not be blocked by a local persistence failure.
      }
      _queueAutosave(state.workingAnswers);
      await _flushAutosave();
    }
    return super.close();
  }
}

class _EssayDraftSnapshot {
  final String lessonId;
  final List<EssayQuestionEntity> questions;
  final Map<int, String> answers;

  const _EssayDraftSnapshot({
    required this.lessonId,
    required this.questions,
    required this.answers,
  });

  bool hasSameAnswers(_EssayDraftSnapshot? other) {
    if (other == null || lessonId != other.lessonId) return false;
    if (answers.length != other.answers.length) return false;
    for (final entry in answers.entries) {
      if (other.answers[entry.key] != entry.value) return false;
    }
    return true;
  }
}
