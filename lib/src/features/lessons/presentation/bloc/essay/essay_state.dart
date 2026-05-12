import 'package:equatable/equatable.dart';

class EssayState extends Equatable {
  final String lessonId;
  final List<String> questions;
  final Map<int, String> workingAnswers;
  final Map<int, String> savedDraftAnswers;
  final int currentQuestionIndex;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;
  final String? snackbarMessage;

  const EssayState({
    this.lessonId = '',
    this.questions = const [],
    this.workingAnswers = const {},
    this.savedDraftAnswers = const {},
    this.currentQuestionIndex = 0,
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
    this.snackbarMessage,
  });

  // Getter pembantu untuk UI agar UI tetap "bodoh"
  int get totalQuestions => questions.length;
  String get currentQuestion => questions.isNotEmpty ? questions[currentQuestionIndex] : '';
  String get currentAnswer => workingAnswers[currentQuestionIndex] ?? '';
  
  bool get isDraftSaved {
    final working = (workingAnswers[currentQuestionIndex] ?? '').trim();
    final saved = (savedDraftAnswers[currentQuestionIndex] ?? '').trim();
    return working == saved;
  }

  int get savedCount => savedDraftAnswers.entries
      .where((e) => e.value.trim().isNotEmpty)
      .length;

  int get currentWordCount {
    final text = currentAnswer.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).length;
  }

  bool get isCurrentQuestionValid => currentWordCount >= 10; // min 10 kata

  Set<int> get savedQuestionIndexes => savedDraftAnswers.entries
      .where((e) => e.value.trim().isNotEmpty)
      .map((e) => e.key)
      .toSet();

  EssayState copyWith({
    String? lessonId,
    List<String>? questions,
    Map<int, String>? workingAnswers,
    Map<int, String>? savedDraftAnswers,
    int? currentQuestionIndex,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
    String? snackbarMessage,
  }) {
    return EssayState(
      lessonId: lessonId ?? this.lessonId,
      questions: questions ?? this.questions,
      workingAnswers: workingAnswers ?? this.workingAnswers,
      savedDraftAnswers: savedDraftAnswers ?? this.savedDraftAnswers,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage, // Dibiarkan null jika tidak di-pass agar ke-reset
      isSuccess: isSuccess ?? this.isSuccess,
      snackbarMessage: snackbarMessage,
    );
  }

  @override
  List<Object?> get props => [
        lessonId,
        questions,
        workingAnswers,
        savedDraftAnswers,
        currentQuestionIndex,
        isSubmitting,
        errorMessage,
        isSuccess,
        snackbarMessage,
      ];
}