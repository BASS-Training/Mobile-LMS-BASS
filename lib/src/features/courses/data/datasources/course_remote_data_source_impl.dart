import '../datasources/dummy_data.dart';
import '../models/course.dart';
import 'course_remote_data_source.dart';

/// Implementasi CourseRemoteDataSource untuk REST API
/// Saat ini menggunakan dummy data, akan diimplementasikan ketika backend ready
class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  // TODO: Tambahkan Dio client ketika backend ready
  // final Dio _dio;
  // CourseRemoteDataSourceImpl(this._dio);

  @override
  Future<List<Course>> getCourses() async {
    // Saat ini return dummy data
    // Nanti ganti dengan:
    // final response = await _dio.get('/api/courses');
    // return (response.data as List).map((c) => Course.fromJson(c)).toList();
    return DummyData.getCourses();
  }

  @override
  Future<Course?> getCourseById(String id) async {
    // Saat ini return dummy data yang sesuai
    final courses = DummyData.getCourses();
    try {
      return courses.firstWhere((course) => course.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Course>> searchCourses(String query) async {
    // Saat ini search di dummy data
    final courses = DummyData.getCourses();
    return courses
        .where(
          (course) =>
              course.title.toLowerCase().contains(query.toLowerCase()) ||
              course.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<void> toggleSaveCourse(String courseId) async {
    // TODO: Implementasikan ketika backend ready
    // Saat ini no-op, status saved disimpan di local saja
  }

  @override
  Future<List<Course>> getSavedCourses() async {
    // Saat ini return semua dummy data (nanti filter dari backend)
    // TODO: Implementasikan filter di backend ketika ready
    return DummyData.getCourses();
  }
}
