/// QuizState - BLoC States
/// Mendefinisikan state-state dari quiz

part of 'quiz_bloc.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class QuizInitial extends QuizState {
  const QuizInitial();
}

/// Loading state - ketika sedang fetch data
class QuizLoading extends QuizState {
  const QuizLoading();
}

/// Loaded state - quiz berhasil dimuat
class QuizLoaded extends QuizState {
  final Quiz quiz;
  final int currentQuestionIndex;
  final Map<int, int> answers; // <questionIndex, selectedOptionIndex>
  final bool isStarted;

  const QuizLoaded({
    required this.quiz,
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.isStarted = false,
  });

  /// Copy with - untuk membuat copy state dengan perubahan tertentu
  QuizLoaded copyWith({
    Quiz? quiz,
    int? currentQuestionIndex,
    Map<int, int>? answers,
    bool? isStarted,
  }) {
    return QuizLoaded(
      quiz: quiz ?? this.quiz,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      isStarted: isStarted ?? this.isStarted,
    );
  }

  @override
  List<Object?> get props => [quiz, currentQuestionIndex, answers, isStarted];
}

/// Submitted state - quiz telah disubmit
class QuizSubmitted extends QuizState {
  final Quiz quiz;
  final QuizResult result;
  final Map<int, int> answers;

  const QuizSubmitted({
    required this.quiz,
    required this.result,
    required this.answers,
  });

  @override
  List<Object?> get props => [quiz, result, answers];
}

/// Error state
class QuizError extends QuizState {
  final String message;

  const QuizError({required this.message});

  @override
  List<Object?> get props => [message];
}
