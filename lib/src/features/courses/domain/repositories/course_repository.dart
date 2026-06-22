import '../entities/course_entity.dart';

/// Kontrak (Domain) untuk data kursus: ambil/cari/refresh, simpan-kursus, dan
/// `watchCourses()` (stream untuk sinkronisasi berkelanjutan). Implementasi di
/// lapisan Data memakai remote (dio) + cache. Contoh kontrak kanonik —
/// lihat ARCHITECTURE.md §3 & §11.
abstract class CourseRepository {
  Future<List<CourseEntity>> getCourses();

  /// Baca daftar course dari cache lokal (disk) saja, tanpa jaringan.
  /// Mengembalikan list kosong bila belum ada cache. Dipakai untuk tampilan
  /// cache-first yang instan sebelum refresh dari jaringan.
  Future<List<CourseEntity>> getCachedCourses();

  Stream<List<CourseEntity>> watchCourses();
  Future<void> addCourse(CourseEntity course);
  Future<CourseEntity?> getCourseById(String id);
  Future<List<CourseEntity>> searchCourses(String query);
  Future<void> toggleSaveCourse(String courseId);
  Future<List<CourseEntity>> getSavedCourses();
  Future<void> refreshCourses();
}
