import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';

class GetSavedCoursesUseCase {
  final CourseRepository repository;

  GetSavedCoursesUseCase(this.repository);

  Future<List<CourseEntity>> call() async {
    return await repository.getSavedCourses();
  }
}