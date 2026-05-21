import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import '../models/course.dart';
import 'course_remote_data_source.dart';

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final Dio dio;

  CourseRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Course>> getCourses() async {
    try {
      final response = await dio.get(ApiEndpoints.getCourses);
      final data = response.data as Map<String, dynamic>;
      final List<dynamic> courseList = data['data'] as List<dynamic>? ?? [];

      return courseList.map((courseJson) {
        final json = Map<String, dynamic>.from(courseJson as Map);
        json['id'] = json['id'].toString();
        return Course.fromJson(json);
      }).toList();
    } on DioException catch (error) {
      throw Exception(
        _extractErrorMessage(error, 'Terjadi kesalahan jaringan'),
      );
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  @override
  Stream<List<Course>> watchCourses() async* {
    // REST API tidak punya Realtime Stream seperti Firestore.
    // Jadi kita panggil getCourses() sekali untuk mengisi stream awal.
    yield await getCourses();
  }

  @override
  Future<Course?> getCourseById(String id) async {
    // Nanti bisa dibuatkan API /courses/{id} di Laravel
    throw UnimplementedError('API getCourseById belum dibuat di Laravel');
  }

  @override
  Future<List<Course>> searchCourses(String query) async {
    // Nanti bisa dibuatkan API search di Laravel
    // Sementara kita filter manual dari semua data
    final courses = await getCourses();
    final normalized = query.toLowerCase();

    return courses
        .where(
          (course) =>
              course.title.toLowerCase().contains(normalized) ||
              course.description.toLowerCase().contains(normalized),
        )
        .toList();
  }

  @override
  Future<void> toggleSaveCourse(String courseId) async {
    // Biarkan kosong, karena save logic di-handle LocalStorage di RepositoryImpl-mu
  }

  @override
  Future<void> addCourse(Course course) async {
    // Nanti dibuatkan API POST /courses di Laravel
    throw UnimplementedError('API POST course belum dibuat di Laravel');
  }

  @override
  Future<List<Course>> getSavedCourses() async {
    throw UnimplementedError('Saved courses masih local-only');
  }

  String _extractErrorMessage(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return fallback;
  }
}
