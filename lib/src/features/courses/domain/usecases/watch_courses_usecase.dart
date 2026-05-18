import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';

class WatchCoursesUseCase {
  final CourseRepository repository;

  WatchCoursesUseCase(this.repository);

  Stream<List<CourseEntity>> call() {
    return repository.watchCourses();
  }
}
