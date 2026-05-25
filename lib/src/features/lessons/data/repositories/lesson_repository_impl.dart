import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import '../../domain/repositories/lesson_repository.dart';
import '../datasources/lesson_remote_datasource.dart';

class LessonRepositoryImpl implements LessonRepository {
  final LessonRemoteDataSource? remoteDataSource;

  LessonRepositoryImpl({this.remoteDataSource});
  @override
  Future<bool> isLessonCompleted(String lessonId) async {
    return LocalStorage.isLessonCompleted(lessonId);
  }

  @override
  Future<void> toggleLessonCompletion(String lessonId) async {
    final isCompleted = LocalStorage.isLessonCompleted(lessonId);

    if (isCompleted) {
      await LocalStorage.unmarkLessonComplete(lessonId);
      try {
        if (remoteDataSource != null) {
          await remoteDataSource!.markLessonIncomplete(lessonId);
        }
      } catch (_) {}
    } else {
      await LocalStorage.markLessonComplete(lessonId);
      try {
        if (remoteDataSource != null) {
          await remoteDataSource!.markLessonComplete(lessonId);
        }
      } catch (_) {}
    }
  }

  @override
  Future<void> markLessonComplete(String lessonId) async {
    if (!LocalStorage.isLessonCompleted(lessonId)) {
      await LocalStorage.markLessonComplete(lessonId);
    }
    try {
      if (remoteDataSource != null) {
        await remoteDataSource!.markLessonComplete(lessonId);
      }
    } catch (_) {}
  }

  @override
  Future<void> markLessonIncomplete(String lessonId) async {
    if (LocalStorage.isLessonCompleted(lessonId)) {
      await LocalStorage.unmarkLessonComplete(lessonId);
    }
    try {
      if (remoteDataSource != null) {
        await remoteDataSource!.markLessonIncomplete(lessonId);
      }
    } catch (_) {}
  }

  @override
  Future<int> getCompletedLessonsCount() async {
    return LocalStorage.getCompletedLessons().length;
  }

  @override
  Future<void> refreshCompletionStatus() async {
    // No-op, but could be used to reload from storage
  }
}
