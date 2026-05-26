import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';
import 'package:lms_mobile_app/src/features/authentication/domain/usecases/auth_usecase.dart';
import '../../../domain/repositories/essay_repository.dart';
import '../../../domain/usecases/submit_essay_usecase.dart';
import 'essay_event.dart';
import 'essay_state.dart';

class EssayBloc extends Bloc<EssayEvent, EssayState> {
  final EssayRepository repository;
  final SubmitEssayUseCase submitUseCase;
  final LessonResultRepository? resultRepository;
  final GetCurrentUserUseCase? getCurrentUserUseCase;
  String _courseId = '';
  String _courseTitle = '';
  String _lessonTitle = '';

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
          isSubmitted: LocalStorage.isEssaySubmitted(event.lessonId),
        ),
      );
    });

    on<AnswerChanged>((event, emit) async {
      final newWorkingAnswers = Map<int, String>.from(state.workingAnswers);
      newWorkingAnswers[state.currentQuestionIndex] = event.answer;
      emit(state.copyWith(workingAnswers: newWorkingAnswers));

      await repository.syncDraftAnswers(
        state.lessonId,
        state.questions,
        newWorkingAnswers,
      );
    });

    on<ChangeQuestion>((event, emit) async {
      // Auto-save draft local memory saat pindah soal
      final currentAnswer =
          state.workingAnswers[state.currentQuestionIndex] ?? '';
      repository.saveDraftAnswer(
        state.lessonId,
        state.currentQuestionIndex,
        currentAnswer,
      );

      final newSavedDrafts = Map<int, String>.from(state.savedDraftAnswers);
      newSavedDrafts[state.currentQuestionIndex] = currentAnswer;

      emit(
        state.copyWith(
          currentQuestionIndex: event.index,
          savedDraftAnswers: newSavedDrafts,
        ),
      );

      await repository.syncDraftAnswers(
        state.lessonId,
        state.questions,
        state.workingAnswers,
      );
    });

    on<SaveDraftClicked>((event, emit) async {
      final currentAnswer =
          state.workingAnswers[state.currentQuestionIndex] ?? '';
      repository.saveDraftAnswer(
        state.lessonId,
        state.currentQuestionIndex,
        currentAnswer,
      );

      final newSavedDrafts = Map<int, String>.from(state.savedDraftAnswers);
      newSavedDrafts[state.currentQuestionIndex] = currentAnswer;

      await repository.syncDraftAnswers(
        state.lessonId,
        state.questions,
        state.workingAnswers,
      );

      emit(
        state.copyWith(
          savedDraftAnswers: newSavedDrafts,
          snackbarMessage: 'Draft jawaban disimpan.',
        ),
      );
    });

    on<SubmitEssayClicked>((event, emit) async {
      emit(state.copyWith(isSubmitting: true));

      // Delay buatan untuk simulasi UX (opsional)
      await Future.delayed(const Duration(milliseconds: 700));

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
}
