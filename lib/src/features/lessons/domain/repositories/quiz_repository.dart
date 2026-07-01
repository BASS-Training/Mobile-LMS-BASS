// Abstract QuizRepository - Domain Layer Contract
// Mengabstraksi akses data untuk domain layer

import 'package:lms_mobile_app/src/features/lessons/domain/entities/quiz_entity.dart';

abstract class QuizRepository {
  /// Get quiz berdasarkan lesson ID
  /// Returns [Quiz] jika berhasil
  /// Throws [Exception] jika gagal
  Future<Quiz> getQuizByLessonId(String lessonId);

  /// Get quiz yang sudah ter-cache di memori, jika ada.
  Quiz? getCachedQuizByLessonId(String lessonId);

  /// Submit quiz answers. Returns a [QuizResult] computed either by server or locally.
  Future<QuizResult> submitQuiz(Quiz quiz, Map<int, int> answers);

  /// Ambil papan peringkat kuis (hanya bila leaderboard diaktifkan admin).
  Future<QuizLeaderboard> getLeaderboard(String quizId);

  /// Buang cache quiz untuk satu lesson (mis. setelah submit, agar status
  /// `completed`/lulus yang baru terbaca ulang dari server saat dibuka lagi).
  void invalidateCachedQuiz(String lessonId);

  /// Buang seluruh cache quiz (mis. saat logout, agar tidak bocor antar-akun).
  void clearQuizCache();
}
