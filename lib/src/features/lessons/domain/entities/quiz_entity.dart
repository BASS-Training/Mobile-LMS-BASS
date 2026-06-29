// Quiz domain entities.
//
// Plain, framework-free data structures for the quiz feature. They carry no
// serialization logic — the data layer (datasources) parses JSON and the
// repository constructs these — so the domain owns them and nothing in the
// domain depends on the data layer.

/// A single quiz question.
class Question {
  final String? id;
  final String text;
  final List<String> options;
  final List<String>? optionIds;

  /// Nullable because the server may not expose the correct answer.
  final int? correctIndex;

  Question({
    this.id,
    required this.text,
    required this.options,
    this.optionIds,
    this.correctIndex,
  });
}

/// The graded outcome of a quiz attempt.
class QuizResult {
  final int score;
  final int total;

  /// Passing threshold (percentage), resolved from the database.
  final int passingScore;

  double get percentage => (score / total) * 100;
  bool get passed => percentage >= passingScore;

  QuizResult({
    required this.score,
    required this.total,
    this.passingScore = 70,
  });
}

/// Quiz metadata plus its questions.
class Quiz {
  final String? id;
  final String title;
  final int totalQuestions;
  final int timeLimit;
  final int passingScore;
  final List<Question> questions;

  /// Optional user-specific info returned by the API.
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

  /// Apakah peserta sudah LULUS kuis ini. Sekali lulus, kuis terkunci dan tidak
  /// bisa dikerjakan lagi; jika belum lulus (termasuk pernah gagal), masih bisa
  /// dikerjakan ulang. Memakai flag `completed` (konten ditandai selesai hanya
  /// saat lulus) ATAU hasil attempt terakhir yang lulus.
  bool get isPassed =>
      completed || (userAttempt != null && userAttempt!['passed'] == true);
}
