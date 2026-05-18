import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';

class AddCourseUseCase {
  final CourseRepository repository;

  AddCourseUseCase(this.repository);

  Future<void> call(CourseEntity course) async {
    return repository.addCourse(course);
  }
}
