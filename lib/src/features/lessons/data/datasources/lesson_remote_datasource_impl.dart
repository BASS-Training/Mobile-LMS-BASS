import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/utils/app_logger.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/lesson_remote_datasource.dart';

class LessonRemoteDataSourceImpl implements LessonRemoteDataSource {
  final Dio dio;

  LessonRemoteDataSourceImpl({required this.dio});

  @override
  Future<void> markLessonComplete(String lessonId) async {
    final endpoint = ApiEndpoints.markLessonComplete.replaceFirst(
      '{id}',
      lessonId,
    );
    try {
      // ignore: avoid_print
      logDebug('[LESSON][REMOTE][COMPLETE] POST $endpoint');
      final response = await dio.post(endpoint);
      // ignore: avoid_print
      logDebug(
        '[LESSON][REMOTE][COMPLETE] RESPONSE ${response.statusCode} ${response.data}',
      );
    } catch (e) {
      // Log and rethrow so caller can handle/log
      // ignore: avoid_print
      logDebug('[LESSON][REMOTE][COMPLETE] ERROR $e');
      rethrow;
    }
  }

  @override
  Future<void> markLessonIncomplete(String lessonId) async {
    final endpoint = ApiEndpoints.markLessonIncomplete.replaceFirst(
      '{id}',
      lessonId,
    );
    try {
      // ignore: avoid_print
      logDebug('[LESSON][REMOTE][INCOMPLETE] POST $endpoint');
      final response = await dio.post(endpoint);
      // ignore: avoid_print
      logDebug(
        '[LESSON][REMOTE][INCOMPLETE] RESPONSE ${response.statusCode} ${response.data}',
      );
    } catch (e) {
      // ignore: avoid_print
      logDebug('[LESSON][REMOTE][INCOMPLETE] ERROR $e');
      rethrow;
    }
  }
}