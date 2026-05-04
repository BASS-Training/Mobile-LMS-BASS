import '../repositories/lesson_repository.dart';

class IsLessonCompletedUseCase {
  final LessonRepository repository;

  IsLessonCompletedUseCase(this.repository);

  Future<bool> call(String lessonId) async {
    return await repository.isLessonCompleted(lessonId);
  }
}

class ToggleLessonCompletionUseCase {
  final LessonRepository repository;

  ToggleLessonCompletionUseCase(this.repository);

  Future<void> call(String lessonId) async {
    return await repository.toggleLessonCompletion(lessonId);
  }
}

class MarkLessonCompleteUseCase {
  final LessonRepository repository;

  MarkLessonCompleteUseCase(this.repository);

  Future<void> call(String lessonId) async {
    return await repository.markLessonComplete(lessonId);
  }
}

class MarkLessonIncompleteUseCase {
  final LessonRepository repository;

  MarkLessonIncompleteUseCase(this.repository);

  Future<void> call(String lessonId) async {
    return await repository.markLessonIncomplete(lessonId);
  }
}

class GetCompletedLessonsCountUseCase {
  final LessonRepository repository;

  GetCompletedLessonsCountUseCase(this.repository);

  Future<int> call() async {
    return await repository.getCompletedLessonsCount();
  }
}

class RefreshLessonCompletionUseCase {
  final LessonRepository repository;

  RefreshLessonCompletionUseCase(this.repository);

  Future<void> call() async {
    return await repository.refreshCompletionStatus();
  }
}
