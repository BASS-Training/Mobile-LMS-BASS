import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';
import '../../../domain/repositories/essay_repository.dart';
import '../../../domain/usecases/submit_essay_usecase.dart';
import 'essay_event.dart';
import 'essay_state.dart';

class EssayBloc extends Bloc<EssayEvent, EssayState> {
  final EssayRepository repository;
  final SubmitEssayUseCase submitUseCase;
  final LessonResultRepository? resultRepository;
  String _courseId = '';
  String _courseTitle = '';
  String _lessonTitle = '';

  EssayBloc({
    required this.repository,
    required this.submitUseCase,
    this.resultRepository,
  }) : super(const EssayState()) {
    on<LoadEssay>((event, emit) {
      _courseId = event.courseId;
      _courseTitle = event.courseTitle;
      _lessonTitle = event.lessonTitle;

      final questions = repository.getQuestions(event.lessonId, event.content);
      final drafts = repository.getDraftAnswers(event.lessonId);

      emit(
        state.copyWith(
          lessonId: event.lessonId,
          questions: questions,
          workingAnswers: Map.from(drafts),
          savedDraftAnswers: Map.from(drafts),
          currentQuestionIndex: 0,
        ),
      );
    });

    on<AnswerChanged>((event, emit) {
      final newWorkingAnswers = Map<int, String>.from(state.workingAnswers);
      newWorkingAnswers[state.currentQuestionIndex] = event.answer;
      emit(state.copyWith(workingAnswers: newWorkingAnswers));
    });

    on<ChangeQuestion>((event, emit) {
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
    });

    on<SaveDraftClicked>((event, emit) {
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
          savedDraftAnswers: newSavedDrafts,
          snackbarMessage: 'Draft jawaban disimpan.',
        ),
      );
    });

    on<SubmitEssayClicked>((event, emit) async {
      emit(state.copyWith(isSubmitting: true));

      // Delay buatan untuk simulasi UX (opsional)
      await Future.delayed(const Duration(milliseconds: 700));

      final isSuccess = await submitUseCase.execute(
        state.lessonId,
        state.workingAnswers,
        state.totalQuestions,
      );

      if (isSuccess) {
        if (resultRepository != null) {
          try {
            final questions = state.questions.asMap().entries.map((entry) {
              final answer = state.workingAnswers[entry.key] ?? '';
              return LessonAttemptQuestionSnapshot(
                questionIndex: entry.key,
                questionText: entry.value,
                options: const [],
                writtenAnswer: answer,
              );
            }).toList();

            await resultRepository!.recordEssaySubmission(
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
          ),
        );
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
