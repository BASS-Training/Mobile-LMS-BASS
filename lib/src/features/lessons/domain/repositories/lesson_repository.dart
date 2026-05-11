abstract class LessonRepository {
  Future<bool> isLessonCompleted(String lessonId);
  Future<void> toggleLessonCompletion(String lessonId);
  Future<void> markLessonComplete(String lessonId);
  Future<void> markLessonIncomplete(String lessonId);
  Future<int> getCompletedLessonsCount();
  Future<void> refreshCompletionStatus();
}
