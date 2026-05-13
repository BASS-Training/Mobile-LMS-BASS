
import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';

class RefreshCoursesUseCase {
  final CourseRepository repository;

  RefreshCoursesUseCase(this.repository);

  Future<void> call() async {
    return await repository.refreshCourses();
  }
}