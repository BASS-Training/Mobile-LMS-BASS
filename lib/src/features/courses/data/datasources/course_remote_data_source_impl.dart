import '../models/course.dart';
import 'course_remote_data_source.dart';

/// Implementasi CourseRemoteDataSource untuk REST API
/// Saat ini placeholder - akan diimplementasi ketika backend ready
class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  // final HttpClient httpClient;
  // final String baseUrl;

  // CourseRemoteDataSourceImpl({
  //   required this.httpClient,
  //   required this.baseUrl,
  // });

  @override
  Future<List<Course>> getCourses() async {
    // TODO: Implementasikan ketika endpoint ready
    // Example:
    // final response = await httpClient.get('$baseUrl/courses');
    // if (response.statusCode == 200) {
    //   return (json.decode(response.body) as List)
    //       .map((c) => Course.fromJson(c))
    //       .toList();
    // } else {
    //   throw Exception('Failed to load courses');
    // }
    throw UnimplementedError(
      'Remote data source belum tersedia, tunggu backend ready',
    );
  }

  @override
  Future<Course?> getCourseById(String id) async {
    // TODO: Implementasikan ketika endpoint ready
    throw UnimplementedError(
      'Remote data source belum tersedia, tunggu backend ready',
    );
  }

  @override
  Future<List<Course>> searchCourses(String query) async {
    // TODO: Implementasikan ketika endpoint ready
    throw UnimplementedError(
      'Remote data source belum tersedia, tunggu backend ready',
    );
  }

  @override
  Future<void> toggleSaveCourse(String courseId) async {
    // TODO: Implementasikan ketika endpoint ready
    throw UnimplementedError(
      'Remote data source belum tersedia, tunggu backend ready',
    );
  }

  @override
  Future<List<Course>> getSavedCourses() async {
    // TODO: Implementasikan ketika endpoint ready
    throw UnimplementedError(
      'Remote data source belum tersedia, tunggu backend ready',
    );
  }
}
