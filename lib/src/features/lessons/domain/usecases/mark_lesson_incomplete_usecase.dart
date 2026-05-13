import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_repository.dart';

class MarkLessonIncompleteUseCase {
  final LessonRepository repository;

  MarkLessonIncompleteUseCase(this.repository);

  Future<void> call(String lessonId) async {
    if (lessonId.isEmpty) {
      throw ArgumentError('Lesson Id tidak boleh kosong');
    }

    return await repository.markLessonIncomplete(lessonId);
  }
}