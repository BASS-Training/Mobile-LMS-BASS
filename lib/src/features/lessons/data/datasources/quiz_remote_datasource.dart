abstract class QuizRemoteDataSource {
  /// Fetch quiz by lesson id from remote API and return normalized map
  Future<Map<String, dynamic>> getQuizByLessonId(String lessonId);

  /// Start an attempt on server and return attempt id
  Future<String> startQuizAttempt(String quizId);

  /// Submit answers to server and return response data map
  Future<Map<String, dynamic>> submitQuizAttempt(
    String quizId,
    String attemptId,
    List<Map<String, dynamic>> answers,
  );

  /// Fetch the leaderboard for a quiz. Returns the raw `data` map from the API
  /// (quizTitle, totalParticipants, currentUserRank, entries).
  Future<Map<String, dynamic>> fetchLeaderboard(String quizId);
}
