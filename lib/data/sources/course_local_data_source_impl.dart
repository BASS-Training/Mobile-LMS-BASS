import '../models/course.dart';
import 'course_local_data_source.dart';
import 'dummy_data.dart';

/// Implementasi CourseLocalDataSource menggunakan DummyData
/// Saat ini belum persistent ke disk (bisa ditingkat ke Hive/SQLite nanti)
class CourseLocalDataSourceImpl implements CourseLocalDataSource {
  List<Course> _cachedCourses = [];

  @override
  Future<List<Course>> getCourses() async {
    // Jika cache kosong, load dari DummyData
    if (_cachedCourses.isEmpty) {
      _cachedCourses = DummyData.getCourses();
    }
    return _cachedCourses;
  }

  @override
  Future<Course?> getCourseById(String id) async {
    // Pastikan cache ada
    if (_cachedCourses.isEmpty) {
      await getCourses();
    }

    try {
      return _cachedCourses.firstWhere((course) => course.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Course>> searchCourses(String query) async {
    // Pastikan cache ada
    if (_cachedCourses.isEmpty) {
      await getCourses();
    }

    return _cachedCourses
        .where(
          (course) =>
              course.title.toLowerCase().contains(query.toLowerCase()) ||
              course.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<void> saveCourse(Course course) async {
    // Cek apakah course sudah ada
    final index = _cachedCourses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _cachedCourses[index] = course;
    } else {
      _cachedCourses.add(course);
    }
    // TODO: Persist ke Hive/SQLite ketika ready
  }

  @override
  Future<void> saveCourses(List<Course> courses) async {
    // Clear existing dan replace dengan new courses
    _cachedCourses = [...courses];
    // TODO: Persist ke Hive/SQLite ketika ready
  }

  @override
  Future<void> toggleSaveCourse(String courseId) async {
    final courseIndex = _cachedCourses.indexWhere((c) => c.id == courseId);
    if (courseIndex != -1) {
      _cachedCourses[courseIndex].isSaved =
          !_cachedCourses[courseIndex].isSaved;
      // TODO: Persist ke Hive/SQLite ketika ready
    }
  }

  @override
  Future<void> clearCourses() async {
    _cachedCourses.clear();
    // TODO: Clear dari Hive/SQLite ketika ready
  }
}
