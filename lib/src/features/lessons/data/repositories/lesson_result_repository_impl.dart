import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';

class LessonResultRepositoryImpl implements LessonResultRepository {
  const LessonResultRepositoryImpl();

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
  }) async {
    final attempts = await _readCourseAttempts(courseId);
    final lessonAttemptCount = attempts
        .where((attempt) => attempt.lessonId == lessonId)
        .length;
    final attempt = LessonAttempt(
      id: _generateAttemptId(lessonId),
      courseId: courseId,
      courseTitle: courseTitle,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      lessonType: 'quiz',
      attemptNumber: lessonAttemptCount + 1,
      submittedAt: DateTime.now(),
      graded: true,
      score: score.toDouble(),
      maxScore: maxScore.toDouble(),
      passed: passed,
      questions: questions,
    );

    attempts.add(attempt);
    await _persistCourseAttempts(courseId, attempts);
    return attempt;
  }

  @override
  Future<LessonAttempt> recordEssaySubmission({
    required String courseId,
    required String courseTitle,
    required String lessonId,
    required String lessonTitle,
    required List<LessonAttemptQuestionSnapshot> questions,
  }) async {
    final attempts = await _readCourseAttempts(courseId);
    final lessonAttemptCount = attempts
        .where((attempt) => attempt.lessonId == lessonId)
        .length;
    final attempt = LessonAttempt(
      id: _generateAttemptId(lessonId),
      courseId: courseId,
      courseTitle: courseTitle,
      lessonId: lessonId,
      lessonTitle: lessonTitle,
      lessonType: 'essay',
      attemptNumber: lessonAttemptCount + 1,
      submittedAt: DateTime.now(),
      graded: false,
      questions: questions,
    );

    attempts.add(attempt);
    await _persistCourseAttempts(courseId, attempts);
    return attempt;
  }

  @override
  Future<List<LessonAttempt>> getAttemptsByCourse(String courseId) async {
    final attempts = await _readCourseAttempts(courseId);
    attempts.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return attempts;
  }

  @override
  Future<List<LessonAttempt>> getAttemptsByLesson({
    required String courseId,
    required String lessonId,
  }) async {
    final attempts = await getAttemptsByCourse(courseId);
    return attempts.where((attempt) => attempt.lessonId == lessonId).toList();
  }

  Future<List<LessonAttempt>> _readCourseAttempts(String courseId) async {
    final rawAttempts = LocalStorage.getLessonAttempts(courseId);
    return rawAttempts
        .map(LessonAttempt.fromJson)
        .where((attempt) => attempt.id.isNotEmpty)
        .toList();
  }

  Future<void> _persistCourseAttempts(
    String courseId,
    List<LessonAttempt> attempts,
  ) async {
    await LocalStorage.saveLessonAttempts(
      courseId: courseId,
      attempts: attempts.map((attempt) => attempt.toJson()).toList(),
    );
  }

  String _generateAttemptId(String lessonId) {
    return '${lessonId}_${DateTime.now().microsecondsSinceEpoch}';
  }
}
