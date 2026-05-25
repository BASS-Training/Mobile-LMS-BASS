part of 'quiz_result_bloc.dart';

abstract class QuizResultEvent extends Equatable {
  const QuizResultEvent();

  @override
  List<Object?> get props => [];
}

class FetchQuizResultEvent extends QuizResultEvent {
  final String courseId;
  final String lessonId;
  final LessonAttempt initialAttempt;

  const FetchQuizResultEvent({
    required this.courseId,
    required this.lessonId,
    required this.initialAttempt,
  });

  @override
  List<Object?> get props => [courseId, lessonId, initialAttempt];
}

class SelectQuizAttemptEvent extends QuizResultEvent {
  final String attemptId;

  const SelectQuizAttemptEvent({required this.attemptId});

  @override
  List<Object?> get props => [attemptId];
}
