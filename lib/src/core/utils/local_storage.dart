import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static const String _boxName = 'mini_lms_box';
  static const String _completedLessonsKey = 'completed_lessons';
  static const String _essayDraftPrefix = 'essay_draft_';

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
}
