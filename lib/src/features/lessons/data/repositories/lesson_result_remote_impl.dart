import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';

class LessonResultRemoteImpl implements LessonResultRepository {
  final Dio dio;

  const LessonResultRemoteImpl({required this.dio});

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
    final attempts = await getAttemptsByCourse(courseId);
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

    await _persistAttempt(attempt);
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
    final attempts = await getAttemptsByCourse(courseId);
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

    await _persistAttempt(attempt);
    return attempt;
  }

  @override
  Future<List<LessonAttempt>> getAttemptsByCourse(String courseId) async {
    try {
      final response = await dio.get('/courses/$courseId/results');
      final data = response.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>? ?? const [];

      final attempts = items
          .whereType<Map>()
          .map(
            (item) => LessonAttempt.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .where((attempt) => attempt.id.isNotEmpty)
          .toList();

      await LocalStorage.saveLessonAttempts(
        courseId: courseId,
        attempts: attempts.map((attempt) => attempt.toJson()).toList(),
      );

      return attempts..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    } catch (_) {
      final rawAttempts = LocalStorage.getLessonAttempts(courseId);
      return rawAttempts
          .map(LessonAttempt.fromJson)
          .where((attempt) => attempt.id.isNotEmpty)
          .toList()
        ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    }
  }

  @override
  Future<List<LessonAttempt>> getAttemptsByLesson({
    required String courseId,
    required String lessonId,
  }) async {
    final attempts = await getAttemptsByCourse(courseId);
    return attempts.where((attempt) => attempt.lessonId == lessonId).toList();
  }

  Future<void> _persistAttempt(LessonAttempt attempt) async {
    final courseId = attempt.courseId;
    final existing = LocalStorage.getLessonAttempts(
      courseId,
    ).map(LessonAttempt.fromJson).where((item) => item.id.isNotEmpty).toList();
    existing.removeWhere((item) => item.id == attempt.id);
    existing.add(attempt);
    await LocalStorage.saveLessonAttempts(
      courseId: courseId,
      attempts: existing.map((item) => item.toJson()).toList(),
    );
  }

  String _generateAttemptId(String lessonId) {
    return '${lessonId}_${DateTime.now().microsecondsSinceEpoch}';
  }
}
