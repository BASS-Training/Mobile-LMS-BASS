/// Quiz Models - Data Layer
///
/// Mendefinisikan struktur data untuk quiz feature termasuk:
/// - Question: Model untuk pertanyaan kuis
/// - QuizResult: Model untuk hasil kuis
/// - Quiz: Metadata kuis

/// Model untuk pertanyaan
class Question {
  final String text;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}

/// Model untuk hasil kuis
class QuizResult {
  final int score;
  final int total;

  double get percentage => (score / total) * 100;
  bool get passed => percentage >= passingScore;

  static const int passingScore = 70;

  QuizResult({required this.score, required this.total});
}

class Quiz {
  final String title;
  final int totalQuestions;
  final int timeLimit;
  final int passingScore;
  final List<Question> questions;

  Quiz({
    required this.title,
    required this.totalQuestions,
    required this.timeLimit,
    required this.passingScore,
    required this.questions,
  });
}

