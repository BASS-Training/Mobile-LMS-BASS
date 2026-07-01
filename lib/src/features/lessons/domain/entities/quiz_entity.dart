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

  /// Apakah admin mengaktifkan leaderboard untuk kuis ini (di web). Bila `true`,
  /// halaman hasil menampilkan papan peringkat Top-5 + peringkat peserta.
  final bool enableLeaderboard;

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
    this.enableLeaderboard = false,
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

/// Satu baris papan peringkat kuis (peserta + skor).
class QuizLeaderboardEntry {
  final int rank;
  final String name;
  final int score;
  final int totalMarks;
  final double percentage;
  final bool passed;

  /// Menandai baris milik peserta yang sedang login (untuk di-highlight).
  final bool isCurrentUser;

  QuizLeaderboardEntry({
    required this.rank,
    required this.name,
    required this.score,
    required this.totalMarks,
    required this.percentage,
    required this.passed,
    required this.isCurrentUser,
  });
}

/// Papan peringkat kuis: daftar peringkat + ringkasan posisi peserta.
class QuizLeaderboard {
  final String quizTitle;
  final int totalParticipants;

  /// Peringkat peserta saat ini (1-based), atau null bila belum ada attempt.
  final int? currentUserRank;
  final List<QuizLeaderboardEntry> entries;

  QuizLeaderboard({
    required this.quizTitle,
    required this.totalParticipants,
    required this.currentUserRank,
    required this.entries,
  });
}
