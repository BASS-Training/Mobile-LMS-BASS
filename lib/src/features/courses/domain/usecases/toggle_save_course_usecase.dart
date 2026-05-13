import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';

class ToggleSaveCourseUseCase {
  final CourseRepository repository;

  ToggleSaveCourseUseCase(this.repository);

  Future<void> call(String courseId) async {
    if (courseId.isEmpty) {
      throw ArgumentError('Course Id tidak boleh kosong');
    }

    final course = await repository.getCourseById(courseId);
    if (course == null) {
      throw ArgumentError('Course dengan ID $courseId tidak ditemukan');
    }

    return await repository.toggleSaveCourse(courseId);
  }
}
