import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/config/flavor_config.dart';
import '../models/course.dart';
import 'course_remote_data_source.dart';

class CourseRemoteDataSourceImpl implements CourseRemoteDataSource {
  final http.Client client;

  CourseRemoteDataSourceImpl({required this.client});

  @override
  Future<List<Course>> getCourses() async {
    try {
      // 1. Ambil Base URL dari Flavor yang sedang aktif (Dev/Prod)
      final baseUrl = FlavorConfig.instance.apiBaseUrl;
      
      // 2. Gabungkan dengan endpoint /courses (Hasilnya: http://127.0.0.1:8000/api/mobile/courses)
      final url = Uri.parse('$baseUrl${ApiEndpoints.getCourses}');
      
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> courseList = jsonResponse['data'];

        return courseList.map((json) {
          // PASTIKAN ID DIUBAH KE STRING (Karena MySQL kirim angka/int, sedangkan Dart butuh String)
          json['id'] = json['id'].toString(); 
          return Course.fromJson(json);
        }).toList();
      } else {
        throw Exception('Gagal mengambil data dari Server: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan: $e');
    }
  }

  @override
  Stream<List<Course>> watchCourses() async* {
    // REST API tidak punya Realtime Stream seperti Firebase.
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
    
    return courses.where((course) =>
        course.title.toLowerCase().contains(normalized) ||
        course.description.toLowerCase().contains(normalized)).toList();
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
}