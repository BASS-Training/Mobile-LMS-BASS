import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/domain/repositories/course_repository.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/add_course_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_cached_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/get_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/refresh_courses_usecase.dart';
import 'package:lms_mobile_app/src/features/courses/domain/usecases/search_courses_usecase.dart';
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

  test('respons get lama tidak menimpa hasil pencarian terbaru', () async {
    final getRequest = Completer<List<CourseEntity>>();
    final searchRequest = Completer<List<CourseEntity>>();
    final repository = _FakeCourseRepository(
      getCoursesRequest: getRequest,
      searchRequests: {'latest': searchRequest},
    );
    final bloc = _courseBloc(repository);

    bloc.add(const GetCoursesEvent());
    await bloc.stream.firstWhere((state) => state is CourseLoading);

    bloc.add(const SearchCoursesEvent(query: 'latest'));
    await _waitUntil(() => repository.searchCoursesCalls == 1);
    searchRequest.complete([_course('latest-course')]);
    await bloc.stream.firstWhere(
      (state) => state is CourseLoaded && state.searchQuery == 'latest',
    );

    getRequest.complete([_course('stale-course')]);
    await Future<void>.delayed(Duration.zero);

    final state = bloc.state as CourseLoaded;
    expect(state.searchQuery, 'latest');
    expect(state.courses.single.id, 'latest-course');
    await bloc.close();
  });

  test('respons pencarian lama tidak menimpa query terbaru', () async {
    final oldSearch = Completer<List<CourseEntity>>();
    final latestSearch = Completer<List<CourseEntity>>();
    final repository = _FakeCourseRepository(
      searchRequests: {'old': oldSearch, 'latest': latestSearch},
    );
    final bloc = _courseBloc(repository);

    bloc.add(const SearchCoursesEvent(query: 'old'));
    await _waitUntil(() => repository.searchCoursesCalls == 1);
    bloc.add(const SearchCoursesEvent(query: 'latest'));
    await _waitUntil(() => repository.searchCoursesCalls == 2);

    latestSearch.complete([_course('latest-course')]);
    await bloc.stream.firstWhere(
      (state) => state is CourseLoaded && state.searchQuery == 'latest',
    );
    oldSearch.complete([_course('stale-course')]);
    await Future<void>.delayed(Duration.zero);

    final state = bloc.state as CourseLoaded;
    expect(state.searchQuery, 'latest');
    expect(state.courses.single.id, 'latest-course');
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
    searchCoursesUseCase: SearchCoursesUseCase(repository),
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
  int searchCoursesCalls = 0;

  Completer<List<CourseEntity>>? getCoursesRequest;
  final Map<String, Completer<List<CourseEntity>>> searchRequests;

  _FakeCourseRepository({
    this.getCoursesRequest,
    this.searchRequests = const {},
  });

  @override
  Future<List<CourseEntity>> getCourses() {
    getCoursesCalls++;
    return getCoursesRequest?.future ?? Future.value(const []);
  }

  @override
  Future<List<CourseEntity>> getCachedCourses() async {
    getCachedCoursesCalls++;
    return const [];
  }

  @override
  Future<void> addCourse(CourseEntity course) => throw UnimplementedError();

  @override
  Future<CourseEntity?> getCourseById(String id) => throw UnimplementedError();

  @override
  Future<List<CourseEntity>> getSavedCourses() => throw UnimplementedError();

  @override
  Future<void> refreshCourses() => throw UnimplementedError();

  @override
  Future<List<CourseEntity>> searchCourses(String query) {
    searchCoursesCalls++;
    final request = searchRequests[query];
    if (request == null) throw StateError('No search request for $query');
    return request.future;
  }

  @override
  Future<void> toggleSaveCourse(String courseId) => throw UnimplementedError();
}
