import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';

class GetCourseByIdUseCase {
  final CourseRepository repository;

  GetCourseByIdUseCase(this.repository);

  Future<CourseEntity?> call(String id) async {
    return await repository.getCourseById(id);
  }
}
