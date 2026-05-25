part of 'quiz_result_bloc.dart';

abstract class QuizResultState extends Equatable {
  const QuizResultState();

  @override
  List<Object?> get props => [];
}

class QuizResultInitial extends QuizResultState {
  const QuizResultInitial();
}

class QuizResultLoading extends QuizResultState {
  const QuizResultLoading();
}

class QuizResultLoaded extends QuizResultState {
  final List<LessonAttempt> attempts;
  final String selectedAttemptId;

  const QuizResultLoaded({
    required this.attempts,
    required this.selectedAttemptId,
  });

  LessonAttempt get selectedAttempt {
    return attempts.firstWhere(
      (attempt) => attempt.id == selectedAttemptId,
      orElse: () => attempts.first,
    );
  }

  QuizResultLoaded copyWith({
    List<LessonAttempt>? attempts,
    String? selectedAttemptId,
  }) {
    return QuizResultLoaded(
      attempts: attempts ?? this.attempts,
      selectedAttemptId: selectedAttemptId ?? this.selectedAttemptId,
    );
  }

  @override
  List<Object?> get props => [attempts, selectedAttemptId];
}

class QuizResultFailure extends QuizResultState {
  final String message;

  const QuizResultFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
