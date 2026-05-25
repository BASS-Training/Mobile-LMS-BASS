import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static const String _boxName = 'mini_lms_box';
  static const String _completedLessonsKey = 'completed_lessons';
  static const String _essayDraftPrefix = 'essay_draft_';
  static const String _lessonAttemptPrefix = 'lesson_attempts_';
  static const String _recentCoursesKey = 'recent_courses';
  static const String _authTokenKey = 'auth_token';
  static const String _authUserKey = 'auth_user';
  static const String _introSeenKey = 'intro_seen';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  // Mark lesson as completed
  static Future<void> markLessonComplete(String lessonId) async {
    final completedLessons = getCompletedLessons();
    if (!completedLessons.contains(lessonId)) {
      completedLessons.add(lessonId);
      await _box.put(_completedLessonsKey, completedLessons);
    }
  }

  // Unmark lesson as completed
  static Future<void> unmarkLessonComplete(String lessonId) async {
    final completedLessons = getCompletedLessons();
    completedLessons.remove(lessonId);
    await _box.put(_completedLessonsKey, completedLessons);
  }

  // Get all completed lessons
  static List<String> getCompletedLessons() {
    final list = _box.get(_completedLessonsKey, defaultValue: <String>[]);
    return List<String>.from(list);
  }

  // Check if lesson is completed
  static bool isLessonCompleted(String lessonId) {
    return getCompletedLessons().contains(lessonId);
  }

  // Clear all completed lessons
  static Future<void> clearAllProgress() async {
    await _box.delete(_completedLessonsKey);
  }

  static List<String> getRecentCourses() {
    final list = _box.get(_recentCoursesKey, defaultValue: <String>[]);
    return List<String>.from(list);
  }

  static Future<void> recordRecentCourse(String courseId) async {
    final recentCourses = getRecentCourses();
    recentCourses.remove(courseId);
    recentCourses.insert(0, courseId);

    if (recentCourses.length > 10) {
      recentCourses.removeRange(10, recentCourses.length);
    }

    await _box.put(_recentCoursesKey, recentCourses);
  }

  static Future<void> clearRecentCourses() async {
    await _box.delete(_recentCoursesKey);
  }

  static Future<void> saveAuthSession({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    await _box.put(_authTokenKey, token);
    await _box.put(_authUserKey, jsonEncode(user));
  }

  static String? getAuthToken() {
    final token = _box.get(_authTokenKey);
    return token is String && token.isNotEmpty ? token : null;
  }

  static Map<String, dynamic>? getAuthUser() {
    final raw = _box.get(_authUserKey);
    if (raw is! String || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
    } catch (_) {}

    return null;
  }

  static Future<void> clearAuthSession() async {
    await _box.delete(_authTokenKey);
    await _box.delete(_authUserKey);
  }

  static bool hasSeenIntro() {
    return _box.get(_introSeenKey, defaultValue: false) == true;
  }

  static Future<void> markIntroSeen() async {
    await _box.put(_introSeenKey, true);
  }

  // Get progress statistics
  static Map<String, dynamic> getProgress() {
    final completedLessons = getCompletedLessons();
    return {
      'completedCount': completedLessons.length,
      'completedLessons': completedLessons,
    };
  }

  static String _essayDraftKey(String lessonId) {
    return '$_essayDraftPrefix$lessonId';
  }

  static Map<int, String> getEssayDraftAnswers(String lessonId) {
    final raw = _box.get(
      _essayDraftKey(lessonId),
      defaultValue: <dynamic, dynamic>{},
    );
    if (raw is! Map) {
      return <int, String>{};
    }

    final result = <int, String>{};
    raw.forEach((key, value) {
      final index = int.tryParse(key.toString());
      if (index == null) return;
      result[index] = value?.toString() ?? '';
    });

    return result;
  }

  static Future<void> saveEssayDraftAnswer({
    required String lessonId,
    required int questionIndex,
    required String answer,
  }) async {
    final current = getEssayDraftAnswers(lessonId);
    current[questionIndex] = answer;
    await _box.put(
      _essayDraftKey(lessonId),
      current.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  static Future<void> saveEssayDraftAnswers({
    required String lessonId,
    required Map<int, String> answers,
  }) async {
    await _box.put(
      _essayDraftKey(lessonId),
      answers.map((key, value) => MapEntry(key.toString(), value)),
    );
  }

  static Future<void> clearEssayDraft(String lessonId) async {
    await _box.delete(_essayDraftKey(lessonId));
  }

  static String _lessonAttemptsKey(String courseId) {
    return '$_lessonAttemptPrefix$courseId';
  }

  static List<Map<String, dynamic>> getLessonAttempts(String courseId) {
    final raw = _box.get(
      _lessonAttemptsKey(courseId),
      defaultValue: <dynamic>[],
    );

    if (raw is! List) {
      return <Map<String, dynamic>>[];
    }

    return raw
        .whereType<Map>()
        .map(
          (entry) => entry.map((key, value) => MapEntry(key.toString(), value)),
        )
        .toList();
  }

  static Future<void> saveLessonAttempts({
    required String courseId,
    required List<Map<String, dynamic>> attempts,
  }) async {
    await _box.put(_lessonAttemptsKey(courseId), attempts);
  }

  static Future<void> clearLessonAttempts(String courseId) async {
    await _box.delete(_lessonAttemptsKey(courseId));
  }
}
