/// Quiz Entities - Domain Layer
///
/// Mendefinisikan struktur data untuk domain layer quiz feature

/// Entity untuk pertanyaan di domain layer
class QuestionEntity {
  final String text;
  final List<String> options;
  final int correctIndex;

  QuestionEntity({
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}

/// Entity untuk hasil kuis di domain layer
class QuizResultEntity {
  final int score;
  final int total;

  double get percentage => (score / total) * 100;
  bool get passed => percentage >= passingScore;

  static const int passingScore = 70;

  QuizResultEntity({required this.score, required this.total});
}

/// Entity untuk metadata kuis di domain layer
class QuizEntity {
  final String title;
  final int totalQuestions;
  final int timeLimit; // dalam menit
  final int passingScore;
  final List<QuestionEntity> questions;

  QuizEntity({
    required this.title,
    required this.totalQuestions,
    required this.timeLimit,
    required this.passingScore,
    required this.questions,
  });
}
