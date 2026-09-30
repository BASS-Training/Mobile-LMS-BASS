import '../entities/course_entity.dart';

/// Kontrak (Domain) untuk data kursus: ambil/refresh dan simpan-kursus.
/// Implementasi di lapisan Data memakai remote (dio) + cache.
abstract class CourseRepository {
  Future<List<CourseEntity>> getCourses();

  /// Baca daftar course dari cache lokal (disk) saja, tanpa jaringan.
  /// Mengembalikan list kosong bila belum ada cache. Dipakai untuk tampilan
  /// cache-first yang instan sebelum refresh dari jaringan.
  Future<List<CourseEntity>> getCachedCourses();

  Future<void> addCourse(CourseEntity course);
  Future<CourseEntity?> getCourseById(String id);
  Future<void> toggleSaveCourse(String courseId);
  Future<List<CourseEntity>> getSavedCourses();
  Future<void> refreshCourses();
}
