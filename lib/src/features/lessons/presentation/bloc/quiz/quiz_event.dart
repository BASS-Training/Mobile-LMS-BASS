/// QuizEvent - BLoC Events
/// Mendefinisikan event-event yang bisa terjadi pada quiz

part of 'quiz_bloc.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

/// Event: Fetch quiz berdasarkan lesson ID
class FetchQuizEvent extends QuizEvent {
  final String lessonId;

  const FetchQuizEvent({required this.lessonId});

  @override
  List<Object?> get props => [lessonId];
}

/// Event: Start quiz
class StartQuizEvent extends QuizEvent {
  const StartQuizEvent();
  @override
  List<Object> get props => [];
}

/// Event: Select answer untuk soal
class SelectAnswerEvent extends QuizEvent {
  final int questionIndex;
  final int selectedOptionIndex;

  const SelectAnswerEvent({
    required this.questionIndex,
    required this.selectedOptionIndex,
  });

  @override
  List<Object?> get props => [questionIndex, selectedOptionIndex];
}

/// Event: Next question
class NextQuestionEvent extends QuizEvent {
  const NextQuestionEvent();
}

/// Event: Previous question
class PreviousQuestionEvent extends QuizEvent {
  const PreviousQuestionEvent();
}

/// Event: Go to specific question
class GoToQuestionEvent extends QuizEvent {
  final int questionIndex;

  const GoToQuestionEvent({required this.questionIndex});

  @override
  List<Object?> get props => [questionIndex];
}

/// Event: Submit quiz dan hitung hasil
class SubmitQuizEvent extends QuizEvent {
  const SubmitQuizEvent();
}

/// Event: Reset quiz ke state awal
class ResetQuizEvent extends QuizEvent {
  const ResetQuizEvent();
}
