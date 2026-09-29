import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_saved_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/cubit/saved_courses_cubit.dart';

void main() {
  test('load menyimpan hasil di state SavedCoursesCubit sendiri', () async {
    final repository = _FakeCourseRepository(
      savedCourses: [_course('saved-course')],
    );
    final cubit = SavedCoursesCubit(
      getSavedCoursesUseCase: GetSavedCoursesUseCase(repository),
    );

    final states = expectLater(
      cubit.stream,
      emitsInOrder([
        const SavedCoursesState(status: SavedCoursesStatus.loading),
        SavedCoursesState(
          status: SavedCoursesStatus.loaded,
          courses: repository.savedCourses,
        ),
      ]),
    );

    await cubit.load();
    await states;

    expect(cubit.state.courses.single.id, 'saved-course');
    await cubit.close();
  });

  test('load menyediakan state failure yang dapat dicoba ulang', () async {
    final repository = _FakeCourseRepository(error: Exception('offline'));
    final cubit = SavedCoursesCubit(
      getSavedCoursesUseCase: GetSavedCoursesUseCase(repository),
    );

    await cubit.load();

    expect(cubit.state.status, SavedCoursesStatus.failure);
    expect(cubit.state.errorMessage, 'Gagal memuat kursus tersimpan.');
    await cubit.close();
  });
}

CourseEntity _course(String id) {
  return CourseEntity(
    id: id,
    title: id,
    description: '',
    instructor: '',
    color: '#000000',
    icon: '',
    chaptersCount: 0,
    duration: '',
    sections: const [],
    lessons: const [],
    isSaved: true,
  );
}

class _FakeCourseRepository implements CourseRepository {
  final List<CourseEntity> savedCourses;
  final Object? error;

  _FakeCourseRepository({this.savedCourses = const [], this.error});

  @override
  Future<List<CourseEntity>> getSavedCourses() async {
    if (error != null) throw error!;
    return savedCourses;
  }

  @override
  Future<void> addCourse(CourseEntity course) => throw UnimplementedError();

  @override
  Future<List<CourseEntity>> getCachedCourses() => throw UnimplementedError();

  @override
  Future<CourseEntity?> getCourseById(String id) => throw UnimplementedError();

  @override
  Future<List<CourseEntity>> getCourses() => throw UnimplementedError();

  @override
  Future<void> refreshCourses() => throw UnimplementedError();

  @override
  Future<List<CourseEntity>> searchCourses(String query) =>
      throw UnimplementedError();

  @override
  Future<void> toggleSaveCourse(String courseId) => throw UnimplementedError();
}
