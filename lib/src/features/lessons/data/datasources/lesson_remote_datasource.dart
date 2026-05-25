import 'package:dio/dio.dart';

abstract class LessonRemoteDataSource {
  Future<void> markLessonComplete(String lessonId);

  Future<void> markLessonIncomplete(String lessonId);
}
