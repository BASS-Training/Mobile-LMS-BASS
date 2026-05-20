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
  final int remainingSeconds; // Timer countdown

  const QuizLoaded({
    required this.quiz,
    this.currentQuestionIndex = 0,
    this.answers = const {},
    this.isStarted = false,
    this.remainingSeconds = 0,
  });

  /// Copy with - untuk membuat copy state dengan perubahan tertentu
  QuizLoaded copyWith({
    Quiz? quiz,
    int? currentQuestionIndex,
    Map<int, int>? answers,
    bool? isStarted,
    int? remainingSeconds,
  }) {
    return QuizLoaded(
      quiz: quiz ?? this.quiz,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      isStarted: isStarted ?? this.isStarted,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  @override
  List<Object?> get props => [
    quiz,
    currentQuestionIndex,
    answers,
    isStarted,
    remainingSeconds,
  ];
}

/// Submitted state - quiz telah disubmit
class QuizSubmitted extends QuizState {
  final Quiz quiz;
  final QuizResult result;
  final Map<int, int> answers;
  final dynamic attempt; // LessonAttempt? kept dynamic to avoid import cycle

  const QuizSubmitted({
    required this.quiz,
    required this.result,
    required this.answers,
    this.attempt,
  });

  @override
  List<Object?> get props => [quiz, result, answers, attempt];
}

/// Error state
class QuizError extends QuizState {
  final String message;

  const QuizError({required this.message});

  @override
  List<Object?> get props => [message];
}
