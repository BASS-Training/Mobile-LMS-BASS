import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_repository.dart';

class ToggleLessonCompletionUseCase {
  final LessonRepository repository;

  ToggleLessonCompletionUseCase(this.repository);

  Future<void> call(String lessonId) async {
    if (lessonId.isEmpty) {
      throw ArgumentError('Lesson Id tidak boleh kosong');
    }

    return await repository.toggleLessonCompletion(lessonId);
  }
}
