import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';

abstract class LessonResultRepository {
  Future<LessonAttempt> recordQuizAttempt({
    required String courseId,
    required String courseTitle,
    required String lessonId,
    required String lessonTitle,
    required List<LessonAttemptQuestionSnapshot> questions,
    required int score,
    required int maxScore,
    required bool passed,
  });

  Future<LessonAttempt> recordEssaySubmission({
    required String courseId,
    required String courseTitle,
    required String lessonId,
    required String lessonTitle,
    required List<LessonAttemptQuestionSnapshot> questions,
  });

  Future<List<LessonAttempt>> getAttemptsByCourse(String courseId);

  Future<List<LessonAttempt>> getAttemptsByLesson({
    required String courseId,
    required String lessonId,
  });
}
