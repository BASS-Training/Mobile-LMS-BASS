import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';

/// Remote implementation (stub) for future API integration.
/// Currently not wired; methods should call backend endpoints and
/// return `LessonAttempt` objects on success.
class LessonResultRemoteImpl implements LessonResultRepository {
  const LessonResultRemoteImpl();

  @override
  Future<LessonAttempt> recordQuizAttempt({
    required String courseId,
    required String courseTitle,
    required String lessonId,
    required String lessonTitle,
    required List<LessonAttemptQuestionSnapshot> questions,
    required int score,
    required int maxScore,
    required bool passed,
  }) {
    throw UnimplementedError('Remote API integration not implemented yet.');
  }

  @override
  Future<LessonAttempt> recordEssaySubmission({
    required String courseId,
    required String courseTitle,
    required String lessonId,
    required String lessonTitle,
    required List<LessonAttemptQuestionSnapshot> questions,
  }) {
    throw UnimplementedError('Remote API integration not implemented yet.');
  }

  @override
  Future<List<LessonAttempt>> getAttemptsByCourse(String courseId) {
    throw UnimplementedError('Remote API integration not implemented yet.');
  }

  @override
  Future<List<LessonAttempt>> getAttemptsByLesson({required String courseId, required String lessonId}) {
    throw UnimplementedError('Remote API integration not implemented yet.');
  }
}
