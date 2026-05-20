/// Abstract QuizRepository - Domain Layer Contract
/// Mengabstraksi akses data untuk domain layer

import 'package:lms_mobile_app/src/features/lessons/data/models/quiz_model.dart';

abstract class QuizRepository {
  /// Get quiz berdasarkan lesson ID
  /// Returns [Quiz] jika berhasil
  /// Throws [Exception] jika gagal
  Future<Quiz> getQuizByLessonId(String lessonId);

  /// Submit quiz answers. Returns a [QuizResult] computed either by server or locally.
  Future<QuizResult> submitQuiz(Quiz quiz, Map<int, int> answers);
}
