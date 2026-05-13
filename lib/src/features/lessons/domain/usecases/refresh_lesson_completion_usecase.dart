import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_repository.dart';

class RefreshLessonCompletionUseCase {
  final LessonRepository repository;

  RefreshLessonCompletionUseCase(this.repository);

  Future<void> call() async {
    return await repository.refreshCompletionStatus();
  }
}
