/// Quiz Models - Data Layer
///
/// Mendefinisikan struktur data untuk quiz feature termasuk:
/// - Question: Model untuk pertanyaan kuis
/// - QuizResult: Model untuk hasil kuis
/// - Quiz: Metadata kuis

/// Model untuk pertanyaan
class Question {
  final String? id;
  final String text;
  final List<String> options;
  final List<String>? optionIds;
  final int?
  correctIndex; // nullable because server may not expose correct answer

  Question({
    this.id,
    required this.text,
    required this.options,
    this.optionIds,
    this.correctIndex,
  });
}

/// Model untuk hasil kuis
class QuizResult {
  final int score;
  final int total;
  final int passingScore; // Dynamic dari database

  double get percentage => (score / total) * 100;
  bool get passed => percentage >= passingScore;

  QuizResult({
    required this.score,
    required this.total,
    this.passingScore = 70, // Default 70 jika tidak diberikan
  });
}

class Quiz {
  final String? id;
  final String title;
  final int totalQuestions;
  final int timeLimit;
  final int passingScore;
  final List<Question> questions;
  // Optional user-specific info returned by API
  final Map<String, dynamic>? userAttempt;
  final bool completed;

  Quiz({
    this.id,
    required this.title,
    required this.totalQuestions,
    required this.timeLimit,
    required this.passingScore,
    required this.questions,
    this.userAttempt,
    this.completed = false,
  });
}
