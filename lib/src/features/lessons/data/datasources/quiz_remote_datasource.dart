import 'package:lms_mobile_app/src/features/lessons/data/models/quiz_model.dart';

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
}
