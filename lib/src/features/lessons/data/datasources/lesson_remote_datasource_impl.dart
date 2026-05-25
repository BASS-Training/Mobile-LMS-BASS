import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/lesson_remote_datasource.dart';

class LessonRemoteDataSourceImpl implements LessonRemoteDataSource {
  final Dio dio;

  LessonRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> markLessonComplete(String lessonId) async {
    final endpoint = ApiEndpoints.markLessonComplete.replaceFirst('{id}', lessonId);
    await dio.post(endpoint);
  }

  @override
  Future<void> markLessonIncomplete(String lessonId) async {
    final endpoint = ApiEndpoints.markLessonIncomplete.replaceFirst('{id}', lessonId);
    await dio.post(endpoint);
  }
}
