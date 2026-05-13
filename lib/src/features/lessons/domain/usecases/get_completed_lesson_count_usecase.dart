import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_repository.dart';

class GetCompletedLessonsCountUsecase {
  final LessonRepository repository;

  GetCompletedLessonsCountUsecase(this.repository);

  Future<int> call() async {
    return await repository.getCompletedLessonsCount();
  }
}