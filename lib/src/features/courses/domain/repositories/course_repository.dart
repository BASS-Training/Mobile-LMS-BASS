import '../entities/course_entity.dart';

/// Kontrak (Domain) untuk data kursus: ambil/cari/refresh, simpan-kursus, dan
/// `watchCourses()` (stream untuk sinkronisasi berkelanjutan). Implementasi di
/// lapisan Data memakai remote (dio) + cache. Contoh kontrak kanonik —
/// lihat ARCHITECTURE.md §3 & §11.
abstract class CourseRepository {
  Future<List<CourseEntity>> getCourses();
  Stream<List<CourseEntity>> watchCourses();
  Future<void> addCourse(CourseEntity course);
  Future<CourseEntity?> getCourseById(String id);
  Future<List<CourseEntity>> searchCourses(String query);
  Future<void> toggleSaveCourse(String courseId);
  Future<List<CourseEntity>> getSavedCourses();
  Future<void> refreshCourses();
}
