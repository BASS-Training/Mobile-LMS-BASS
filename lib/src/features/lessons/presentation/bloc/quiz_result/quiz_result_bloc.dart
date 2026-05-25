import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';

part 'quiz_result_event.dart';
part 'quiz_result_state.dart';

class QuizResultBloc extends Bloc<QuizResultEvent, QuizResultState> {
  final LessonResultRepository resultRepository;

  QuizResultBloc({required this.resultRepository})
    : super(const QuizResultInitial()) {
    on<FetchQuizResultEvent>(_onFetchQuizResult);
    on<SelectQuizAttemptEvent>(_onSelectQuizAttempt);
  }

  Future<void> _onFetchQuizResult(
    FetchQuizResultEvent event,
    Emitter<QuizResultState> emit,
  ) async {
    emit(const QuizResultLoading());
    try {
      final attempts = await resultRepository.getAttemptsByLesson(
        courseId: event.courseId,
        lessonId: event.lessonId,
      );

      final resolvedAttempts = attempts.isNotEmpty
          ? attempts
          : <LessonAttempt>[event.initialAttempt];
      final selectedAttemptId =
          resolvedAttempts.any(
            (attempt) => attempt.id == event.initialAttempt.id,
          )
          ? event.initialAttempt.id
          : resolvedAttempts.first.id;

      emit(
        QuizResultLoaded(
          attempts: resolvedAttempts,
          selectedAttemptId: selectedAttemptId,
        ),
      );
    } catch (error) {
      emit(QuizResultFailure(message: error.toString()));
    }
  }

  void _onSelectQuizAttempt(
    SelectQuizAttemptEvent event,
    Emitter<QuizResultState> emit,
  ) {
    final currentState = state;
    if (currentState is QuizResultLoaded) {
      emit(currentState.copyWith(selectedAttemptId: event.attemptId));
    }
  }
}
