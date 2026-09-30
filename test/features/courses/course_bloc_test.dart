import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/add_course_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_cached_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/refresh_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/toggle_save_course_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_state.dart';

void main() {
  test('tidak mengambil course otomatis saat CourseBloc dibuat', () async {
    final repository = _FakeCourseRepository();
    final bloc = _courseBloc(repository);

    await Future<void>.delayed(Duration.zero);

    expect(repository.getCoursesCalls, 0);
    expect(repository.getCachedCoursesCalls, 0);

    bloc.add(const GetCoursesEvent());
    await bloc.stream.firstWhere((state) => state is CourseLoaded);

    expect(repository.getCoursesCalls, 1);
    expect(repository.getCachedCoursesCalls, 1);
    await bloc.close();
  });

  test(
    'CourseLoaded memakai daftar tampil sebagai canonical secara default',
    () {
      final courses = [_course('course-1'), _course('course-2')];

      final state = CourseLoaded(courses: courses);

      expect(state.allCourses, same(courses));
    },
  );

  test('get dan refresh berbagi request course yang sedang berjalan', () async {
    final request = Completer<List<CourseEntity>>();
    final repository = _FakeCourseRepository(getCoursesRequest: request);
    final bloc = _courseBloc(repository);
    final firstRefreshDone = Completer<void>();
    final secondRefreshDone = Completer<void>();

    bloc.add(const GetCoursesEvent());
    await bloc.stream.firstWhere((state) => state is CourseLoading);

    bloc.add(RefreshCoursesEvent(onComplete: firstRefreshDone));
    bloc.add(RefreshCoursesEvent(onComplete: secondRefreshDone));
    await Future<void>.delayed(Duration.zero);

    expect(repository.getCoursesCalls, 1);

    request.complete(const []);
    await Future.wait([firstRefreshDone.future, secondRefreshDone.future]);

    expect(repository.getCoursesCalls, 1);
    await bloc.close();
  });

  test(
    'request baru dapat berjalan setelah request sebelumnya gagal',
    () async {
      final firstRequest = Completer<List<CourseEntity>>();
      final repository = _FakeCourseRepository(getCoursesRequest: firstRequest);
      final bloc = _courseBloc(repository);
      final firstRefreshDone = Completer<void>();

      bloc.add(RefreshCoursesEvent(onComplete: firstRefreshDone));
      await _waitUntil(() => repository.getCoursesCalls == 1);
      firstRequest.completeError(Exception('offline'));
      await firstRefreshDone.future;

      final secondRequest = Completer<List<CourseEntity>>();
      repository.getCoursesRequest = secondRequest;
      final secondRefreshDone = Completer<void>();
      bloc.add(RefreshCoursesEvent(onComplete: secondRefreshDone));
      await _waitUntil(() => repository.getCoursesCalls == 2);
      secondRequest.complete(const []);
      await secondRefreshDone.future;

      expect(repository.getCoursesCalls, 2);
      await bloc.close();
    },
  );

  test('reload mempertahankan hasil lama tanpa CourseLoading', () async {
    final repository = _FakeCourseRepository(courses: [_course('existing')]);
    final bloc = _courseBloc(repository);

    bloc.add(const GetCoursesEvent());
    await bloc.stream.firstWhere((state) => state is CourseLoaded);

    final reloadRequest = Completer<List<CourseEntity>>();
    repository.getCoursesRequest = reloadRequest;
    final emittedStates = <CourseState>[];
    final subscription = bloc.stream.listen(emittedStates.add);
    bloc.add(const GetCoursesEvent());
    await _waitUntil(() => repository.getCoursesCalls == 2);

    expect(bloc.state, isA<CourseLoaded>());
    expect(emittedStates.whereType<CourseLoading>(), isEmpty);

    reloadRequest.complete([_course('updated')]);
    final updated =
        await bloc.stream.firstWhere(
              (state) =>
                  state is CourseLoaded &&
                  state.allCourses.single.id == 'updated',
            )
            as CourseLoaded;

    expect(updated.courses.single.id, 'updated');
    await subscription.cancel();
    await bloc.close();
  });

  test('search memfilter hasil tanpa CourseLoading', () async {
    final repository = _FakeCourseRepository(
      courses: [_course('bass'), _course('groove')],
    );
    final bloc = _courseBloc(repository);

    bloc.add(const GetCoursesEvent());
    await bloc.stream.firstWhere((state) => state is CourseLoaded);

    final emittedStates = <CourseState>[];
    final subscription = bloc.stream.listen(emittedStates.add);
    bloc.add(const SearchCoursesEvent(query: 'bass'));
    await bloc.stream.firstWhere(
      (state) => state is CourseLoaded && state.searchQuery == 'bass',
    );

    expect(emittedStates.whereType<CourseLoading>(), isEmpty);
    await subscription.cancel();
    await bloc.close();
  });

  test('query saat initial load diterapkan setelah course tersedia', () async {
    final getRequest = Completer<List<CourseEntity>>();
    final repository = _FakeCourseRepository(getCoursesRequest: getRequest);
    final bloc = _courseBloc(repository);

    bloc.add(const GetCoursesEvent());
    await bloc.stream.firstWhere((state) => state is CourseLoading);

    bloc.add(const SearchCoursesEvent(query: 'latest'));
    getRequest.complete([_course('latest-course'), _course('other-course')]);
    final state =
        await bloc.stream.firstWhere(
              (state) => state is CourseLoaded && state.searchQuery == 'latest',
            )
            as CourseLoaded;

    expect(state.courses.single.id, 'latest-course');
    expect(state.allCourses, hasLength(2));
    expect(repository.getCoursesCalls, 1);
    await bloc.close();
  });

  test('pencarian berulang hanya memfilter canonical list', () async {
    final repository = _FakeCourseRepository(
      courses: [_course('old-course'), _course('latest-course')],
    );
    final bloc = _courseBloc(repository);

    bloc.add(const GetCoursesEvent());
    await bloc.stream.firstWhere((state) => state is CourseLoaded);
    bloc.add(const SearchCoursesEvent(query: 'old'));
    await bloc.stream.firstWhere(
      (state) => state is CourseLoaded && state.searchQuery == 'old',
    );
    bloc.add(const SearchCoursesEvent(query: 'latest'));
    final state =
        await bloc.stream.firstWhere(
              (state) => state is CourseLoaded && state.searchQuery == 'latest',
            )
            as CourseLoaded;

    expect(state.courses.single.id, 'latest-course');
    expect(repository.getCoursesCalls, 1);
    await bloc.close();
  });

  test('query dinormalisasi dan query identik tidak emit ulang', () async {
    final repository = _FakeCourseRepository(
      courses: [_course('bass'), _course('groove')],
    );
    final bloc = _courseBloc(repository);

    bloc.add(const GetCoursesEvent());
    await bloc.stream.firstWhere((state) => state is CourseLoaded);

    final emittedStates = <CourseState>[];
    final subscription = bloc.stream.listen(emittedStates.add);
    bloc.add(const SearchCoursesEvent(query: '  BaSs  '));
    final searched =
        await bloc.stream.firstWhere(
              (state) => state is CourseLoaded && state.searchQuery == 'bass',
            )
            as CourseLoaded;
    final emissionCount = emittedStates.length;

    bloc.add(const SearchCoursesEvent(query: 'BASS'));
    await Future<void>.delayed(Duration.zero);

    expect(searched.courses.single.id, 'bass');
    expect(emittedStates, hasLength(emissionCount));
    expect(repository.getCoursesCalls, 1);
    await subscription.cancel();
    await bloc.close();
  });

  test('hasil pencarian tidak mengganti canonical course', () async {
    final allCourses = [_course('bass'), _course('groove')];
    final repository = _FakeCourseRepository(courses: allCourses);
    final bloc = _courseBloc(repository);

    bloc.add(const GetCoursesEvent());
    await bloc.stream.firstWhere(
      (state) => state is CourseLoaded && state.allCourses.length == 2,
    );

    bloc.add(const SearchCoursesEvent(query: 'bass'));
    final searched =
        await bloc.stream.firstWhere(
              (state) => state is CourseLoaded && state.searchQuery == 'bass',
            )
            as CourseLoaded;

    expect(searched.courses.map((course) => course.id), ['bass']);
    expect(searched.allCourses.map((course) => course.id), ['bass', 'groove']);
    await bloc.close();
  });

  test('toggle save memperbarui daftar tampil dan canonical', () async {
    final repository = _FakeCourseRepository(courses: [_course('bass')]);
    final bloc = _courseBloc(repository);

    bloc.add(const GetCoursesEvent());
    await bloc.stream.firstWhere((state) => state is CourseLoaded);
    bloc.add(const ToggleSaveCourseEvent(courseId: 'bass'));
    final toggled =
        await bloc.stream.firstWhere(
              (state) =>
                  state is CourseLoaded &&
                  state.allCourses.single.isSaved == true,
            )
            as CourseLoaded;

    expect(toggled.courses.single.isSaved, isTrue);
    expect(toggled.allCourses.single.isSaved, isTrue);
    await bloc.close();
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
  );
}

CourseBloc _courseBloc(CourseRepository repository) {
  return CourseBloc(
    getCoursesUseCase: GetCoursesUseCase(repository),
    getCachedCoursesUseCase: GetCachedCoursesUseCase(repository),
    toggleSaveCourseUseCase: ToggleSaveCourseUseCase(repository),
    refreshCoursesUseCase: RefreshCoursesUseCase(repository),
    addCourseUseCase: AddCourseUseCase(repository),
  );
}

Future<void> _waitUntil(bool Function() condition) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    if (condition()) return;
    await Future<void>.delayed(Duration.zero);
  }
  fail('Condition was not met');
}

class _FakeCourseRepository implements CourseRepository {
  int getCoursesCalls = 0;
  int getCachedCoursesCalls = 0;

  Completer<List<CourseEntity>>? getCoursesRequest;
  final List<CourseEntity> courses;

  _FakeCourseRepository({this.getCoursesRequest, this.courses = const []});

  @override
  Future<List<CourseEntity>> getCourses() {
    getCoursesCalls++;
    return getCoursesRequest?.future ?? Future.value(courses);
  }

  @override
  Future<List<CourseEntity>> getCachedCourses() async {
    getCachedCoursesCalls++;
    return const [];
  }

  @override
  Future<void> addCourse(CourseEntity course) => throw UnimplementedError();

  @override
  Future<CourseEntity?> getCourseById(String id) async {
    for (final course in courses) {
      if (course.id == id) return course;
    }
    return null;
  }

  @override
  Future<List<CourseEntity>> getSavedCourses() => throw UnimplementedError();

  @override
  Future<void> refreshCourses() => throw UnimplementedError();

  @override
  Future<void> toggleSaveCourse(String courseId) async {}
}
