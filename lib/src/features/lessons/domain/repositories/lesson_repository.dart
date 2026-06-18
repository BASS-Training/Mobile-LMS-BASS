/// Kontrak (Domain) untuk status penyelesaian lesson (selesai/belum, toggle,
/// hitungan). Implementasi di lapisan Data menyinkronkan ke backend + cache
/// lokal. Lihat ARCHITECTURE.md §3.
abstract class LessonRepository {
  Future<bool> isLessonCompleted(String lessonId);
  Future<void> toggleLessonCompletion(String lessonId);
  Future<void> markLessonComplete(String lessonId);
  Future<void> markLessonIncomplete(String lessonId);
  Future<int> getCompletedLessonsCount();
  Future<void> refreshCompletionStatus();
}
