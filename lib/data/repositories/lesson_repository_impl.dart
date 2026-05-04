import '../../domain/repositories/lesson_repository.dart';
import '../sources/local_storage.dart';

class LessonRepositoryImpl implements LessonRepository {
  @override
  Future<bool> isLessonCompleted(String lessonId) async {
    return LocalStorage.isLessonCompleted(lessonId);
  }

  @override
  Future<void> toggleLessonCompletion(String lessonId) async {
    final isCompleted = LocalStorage.isLessonCompleted(lessonId);

    if (isCompleted) {
      await LocalStorage.unmarkLessonComplete(lessonId);
    } else {
      await LocalStorage.markLessonComplete(lessonId);
    }
  }

  @override
  Future<void> markLessonComplete(String lessonId) async {
    if (!LocalStorage.isLessonCompleted(lessonId)) {
      await LocalStorage.markLessonComplete(lessonId);
    }
  }

  @override
  Future<void> markLessonIncomplete(String lessonId) async {
    if (LocalStorage.isLessonCompleted(lessonId)) {
      await LocalStorage.unmarkLessonComplete(lessonId);
    }
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
