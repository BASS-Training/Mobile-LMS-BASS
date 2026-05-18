import '../models/course.dart';

/// Abstract contract untuk remote course data source
/// Implementasi akan menggunakan REST API atau GraphQL
abstract class CourseRemoteDataSource {
  /// Get semua courses dari remote API
  Future<List<Course>> getCourses();

  /// Stream perubahan course untuk sync real-time
  Stream<List<Course>> watchCourses();

  /// Get course berdasarkan ID dari remote
  Future<Course?> getCourseById(String id);

  /// Search courses dari remote
  Future<List<Course>> searchCourses(String query);

  /// Toggle save course di remote
  Future<void> toggleSaveCourse(String courseId);

  /// Tambah course baru ke remote
  Future<void> addCourse(Course course);

  /// Get saved courses dari remote
  Future<List<Course>> getSavedCourses();
}
