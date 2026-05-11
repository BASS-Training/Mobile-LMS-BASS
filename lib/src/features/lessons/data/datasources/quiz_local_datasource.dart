/// Abstract QuizLocalDataSource - Data Layer Contract
abstract class QuizLocalDataSource {
  /// Get quiz berdasarkan lesson ID
  /// Throws [Exception] jika quiz tidak ditemukan
  Future<Map<String, dynamic>> getQuizByLessonId(String lessonId);
}
