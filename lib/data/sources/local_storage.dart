import 'package:hive_flutter/hive_flutter.dart';

class LocalStorage {
  static const String _boxName = 'mini_lms_box';
  static const String _completedLessonsKey = 'completed_lessons';

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
}
