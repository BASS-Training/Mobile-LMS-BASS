import '../models/course.dart';

/// Abstract contract untuk remote course data source
/// Implementasi akan menggunakan REST API atau GraphQL
abstract class CourseRemoteDataSource {
  /// Get semua courses dari remote API
  Future<List<Course>> getCourses();

  /// Get course berdasarkan ID dari remote
  Future<Course?> getCourseById(String id);

  /// Search courses dari remote
  Future<List<Course>> searchCourses(String query);

  /// Toggle save course di remote
  Future<void> toggleSaveCourse(String courseId);

  /// Get saved courses dari remote
  Future<List<Course>> getSavedCourses();
}
