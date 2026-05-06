import '../entities/course_entity.dart';
import '../repositories/course_repository.dart';

class GetCoursesUseCase {
  final CourseRepository repository;

  GetCoursesUseCase(this.repository);

  Future<List<CourseEntity>> call() async {
    return await repository.getCourses();
  }
}

class GetCourseByIdUseCase {
  final CourseRepository repository;

  GetCourseByIdUseCase(this.repository);

  Future<CourseEntity?> call(String id) async {
    return await repository.getCourseById(id);
  }
}

class SearchCoursesUseCase {
  final CourseRepository repository;

  SearchCoursesUseCase(this.repository);

  Future<List<CourseEntity>> call(String query) async {
    return await repository.searchCourses(query);
  }
}

class ToggleSaveCourseUseCase {
  final CourseRepository repository;

  ToggleSaveCourseUseCase(this.repository);

  /// Toggle save course dengan validation
  /// @throws ArgumentError jika courseId invalid
  Future<void> call(String courseId) async {
    // Validasi courseId
    if (courseId.isEmpty) {
      throw ArgumentError('Course ID tidak boleh kosong');
    }

    // Validasi bahwa course exist
    final course = await repository.getCourseById(courseId);
    if (course == null) {
      throw ArgumentError('Course dengan ID $courseId tidak ditemukan');
    }

    return await repository.toggleSaveCourse(courseId);
  }
}

class GetSavedCoursesUseCase {
  final CourseRepository repository;

  GetSavedCoursesUseCase(this.repository);

  Future<List<CourseEntity>> call() async {
    return await repository.getSavedCourses();
  }
}

class RefreshCoursesUseCase {
  final CourseRepository repository;

  RefreshCoursesUseCase(this.repository);

  Future<void> call() async {
    return await repository.refreshCourses();
  }
}
