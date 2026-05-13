import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';

class SearchCoursesUseCase {
  final CourseRepository repository;

  SearchCoursesUseCase(this.repository);

  Future<List<CourseEntity>> call(String query) async {
    return await repository.searchCourses(query);
  }
}