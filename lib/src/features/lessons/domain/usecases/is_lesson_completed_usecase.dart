import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_repository.dart';

class IsLessonCompletedUseCase {
  final LessonRepository repository;

  IsLessonCompletedUseCase(this.repository);

  Future<bool> call(String lessonId) async {
    return await repository.isLessonCompleted(lessonId);
  }
}