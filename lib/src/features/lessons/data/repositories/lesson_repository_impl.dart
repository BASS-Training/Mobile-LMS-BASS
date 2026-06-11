import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/core/utils/app_logger.dart';
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
      // Try to sync remote with retries
      if (remoteDataSource != null) {
        var attempts = 0;
        while (attempts < 3) {
          attempts += 1;
          try {
            await remoteDataSource!.markLessonComplete(lessonId);
            break;
          } catch (e) {
            // ignore: avoid_print
            logDebug('markLessonComplete attempt=$attempts failed: $e');
            if (attempts >= 3) {
              // Give up after 3 attempts; will leave local mark so user can continue offline
              // Could schedule background retry here
            } else {
              await Future.delayed(const Duration(seconds: 1));
            }
          }
        }
      }
    }
  }

  @override
  Future<void> markLessonComplete(String lessonId) async {
    if (!LocalStorage.isLessonCompleted(lessonId)) {
      await LocalStorage.markLessonComplete(lessonId);
    }
    try {
      if (remoteDataSource != null) {
        var attempts = 0;
        while (attempts < 3) {
          attempts += 1;
          try {
            await remoteDataSource!.markLessonComplete(lessonId);
            break;
          } catch (e) {
            // ignore: avoid_print
            logDebug('markLessonComplete attempt=$attempts failed: $e');
            if (attempts >= 3) {
              // final failure
            } else {
              await Future.delayed(const Duration(seconds: 1));
            }
          }
        }
      }
    } catch (e, st) {
      // Log remote failure for debugging
      // ignore: avoid_print
      logDebug('markLessonComplete remote error: $e');
      // ignore: avoid_print
      logDebug(st);
    }
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