import '../models/course.dart';

/// Abstract contract untuk local course data source
/// Bisa implementasi dari Hive, SQLite, atau DummyData
abstract class CourseLocalDataSource {
  /// Get semua courses dari local storage
  Future<List<Course>> getCourses();

  /// Get course berdasarkan ID
  Future<Course?> getCourseById(String id);

  /// Search courses
  Future<List<Course>> searchCourses(String query);

  /// Save course ke local
  Future<void> saveCourse(Course course);

  /// Save multiple courses sekaligus (untuk cache)
  Future<void> saveCourses(List<Course> courses);

  /// Toggle save status course
  Future<void> toggleSaveCourse(String courseId);

  /// Clear all local courses
  Future<void> clearCourses();
}
