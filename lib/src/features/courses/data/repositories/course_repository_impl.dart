import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/core/utils/offline_test_mode.dart';

import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../mappers/course_mapper.dart';
import '../models/course.dart';
import '../datasources/course_local_data_source.dart';
import '../datasources/course_remote_data_source.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseLocalDataSource localDataSource;
  final CourseRemoteDataSource remoteDataSource;

  CourseRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<CourseEntity>> getCourses() async {
    if (_isOfflineTestSession()) {
      print(
        '[COURSE][FETCH] using local dummy getCourses tester=${OfflineTestMode.describeContext()}',
      );
      final localCourses = await localDataSource.getCourses();
      _updateCompletionStatus(localCourses);
      return _mapCoursesToEntities(localCourses);
    }

    try {
      print(
        '[COURSE][FETCH] using remote API getCourses tester=${OfflineTestMode.describeContext()}',
      );
      // Strategi: Coba remote dulu untuk data terbaru
      final remoteCourses = await remoteDataSource.getCourses();
      // Simpan ke cache local
      await localDataSource.saveCourses(remoteCourses);
      _updateCompletionStatus(remoteCourses);
      return _mapCoursesToEntities(remoteCourses);
    } catch (e) {
      // Fallback ke local cache jika remote gagal
      print("===== ERROR DARI LARAVEL: $e =====");
      final localCourses = await localDataSource.getCourses();
      _updateCompletionStatus(localCourses);
      return _mapCoursesToEntities(localCourses);
    }
  }

  @override
  Stream<List<CourseEntity>> watchCourses() async* {
    if (_isOfflineTestSession()) {
      print(
        '[COURSE][WATCH] using local dummy watchCourses tester=${OfflineTestMode.describeContext()}',
      );
      final localCourses = await localDataSource.getCourses();
      _updateCompletionStatus(localCourses);
      yield _mapCoursesToEntities(localCourses);
      return;
    }

    print(
      '[COURSE][WATCH] using remote API watchCourses tester=${OfflineTestMode.describeContext()}',
    );
    await for (final courses in remoteDataSource.watchCourses()) {
      _updateCompletionStatus(courses);
      yield _mapCoursesToEntities(courses);
    }
  }

  @override
  Future<CourseEntity?> getCourseById(String id) async {
    if (_isOfflineTestSession()) {
      print(
        '[COURSE][DETAIL] using local dummy getCourseById id=$id tester=${OfflineTestMode.describeContext()}',
      );
      final localCourse = await localDataSource.getCourseById(id);
      if (localCourse != null) {
        _updateCompletionStatus([localCourse]);
        return CourseMapper.toDomain(localCourse);
      }
      return null;
    }

    try {
      print(
        '[COURSE][DETAIL] using remote API getCourseById id=$id tester=${OfflineTestMode.describeContext()}',
      );
      // Coba remote dulu
      final remoteCourse = await remoteDataSource.getCourseById(id);
      if (remoteCourse != null) {
        // Simpan ke cache
        await localDataSource.saveCourse(remoteCourse);
        _updateCompletionStatus([remoteCourse]);
        return CourseMapper.toDomain(remoteCourse);
      }
    } catch (e) {
      // Fallback ke local
    }

    // Jika remote gagal atau return null, cek local
    final localCourse = await localDataSource.getCourseById(id);
    if (localCourse != null) {
      _updateCompletionStatus([localCourse]);
      return CourseMapper.toDomain(localCourse);
    }

    return null;
  }

  @override
  Future<List<CourseEntity>> searchCourses(String query) async {
    if (_isOfflineTestSession()) {
      print(
        '[COURSE][SEARCH] using local dummy searchCourses query=$query tester=${OfflineTestMode.describeContext()}',
      );
      final localCourses = await localDataSource.searchCourses(query);
      _updateCompletionStatus(localCourses);
      return _mapCoursesToEntities(localCourses);
    }

    try {
      print(
        '[COURSE][SEARCH] using remote API searchCourses query=$query tester=${OfflineTestMode.describeContext()}',
      );
      // Coba remote dulu
      final remoteCourses = await remoteDataSource.searchCourses(query);
      // Simpan ke cache
      await localDataSource.saveCourses(remoteCourses);
      _updateCompletionStatus(remoteCourses);
      return _mapCoursesToEntities(remoteCourses);
    } catch (e) {
      // Fallback ke local cache
      final localCourses = await localDataSource.searchCourses(query);
      _updateCompletionStatus(localCourses);
      return _mapCoursesToEntities(localCourses);
    }
  }

  @override
  Future<void> toggleSaveCourse(String courseId) async {
    // Update di local
    await localDataSource.toggleSaveCourse(courseId);

    // Update di remote (non-blocking)
    try {
      await remoteDataSource.toggleSaveCourse(courseId);
    } catch (e) {
      // Biarkan sync nanti atau ignore jika offline
    }
  }

  @override
  Future<void> addCourse(CourseEntity course) async {
    final model = CourseMapper.fromDomain(course);
    if (_isOfflineTestSession()) {
      print(
        '[COURSE][ADD] using local dummy addCourse id=${course.id} tester=${OfflineTestMode.describeContext()}',
      );
      await localDataSource.saveCourse(model);
      return;
    }

    print(
      '[COURSE][ADD] using remote API addCourse id=${course.id} tester=${OfflineTestMode.describeContext()}',
    );
    await remoteDataSource.addCourse(model);
    await localDataSource.saveCourse(model);
  }

  @override
  Future<List<CourseEntity>> getSavedCourses() async {
    if (_isOfflineTestSession()) {
      print(
        '[COURSE][SAVED] using local dummy getSavedCourses tester=${OfflineTestMode.describeContext()}',
      );
      final localCourses = await localDataSource.getCourses();
      final savedCourses = localCourses.where((c) => c.isSaved).toList();
      _updateCompletionStatus(savedCourses);
      return _mapCoursesToEntities(savedCourses);
    }

    try {
      print(
        '[COURSE][SAVED] using remote API getSavedCourses tester=${OfflineTestMode.describeContext()}',
      );
      // Coba remote dulu untuk list terbaru
      final remoteSavedCourses = await remoteDataSource.getSavedCourses();
      // Simpan ke cache
      await localDataSource.saveCourses(remoteSavedCourses);
      _updateCompletionStatus(remoteSavedCourses);
      return _mapCoursesToEntities(remoteSavedCourses);
    } catch (e) {
      // Fallback ke local cache
      final localCourses = await localDataSource.getCourses();
      final savedCourses = localCourses.where((c) => c.isSaved).toList();
      _updateCompletionStatus(savedCourses);
      return _mapCoursesToEntities(savedCourses);
    }
  }

  @override
  Future<void> refreshCourses() async {
    if (_isOfflineTestSession()) {
      print(
        '[COURSE][REFRESH] using local dummy refreshCourses tester=${OfflineTestMode.describeContext()}',
      );
      final localCourses = await localDataSource.getCourses();
      _updateCompletionStatus(localCourses);
      return;
    }

    print(
      '[COURSE][REFRESH] using remote API refreshCourses tester=${OfflineTestMode.describeContext()}',
    );
    // Refresh akan coba remote dulu, fallback ke local
    try {
      final remoteCourses = await remoteDataSource.getCourses();
      await localDataSource.saveCourses(remoteCourses);
      _updateCompletionStatus(remoteCourses);
    } catch (e) {
      // Jika remote gagal, biarkan pakai cache yang ada
      final localCourses = await localDataSource.getCourses();
      _updateCompletionStatus(localCourses);
    }
  }

  /// Map list of courses ke list of entities
  List<CourseEntity> _mapCoursesToEntities(List<Course> courses) {
    return courses.map((c) => CourseMapper.toDomain(c)).toList();
  }

  /// Update completion status dari LocalStorage
  void _updateCompletionStatus(List<Course> courses) {
    final completedLessons = LocalStorage.getCompletedLessons();
    for (var course in courses) {
      for (var lesson in course.lessons) {
        lesson.isCompleted = completedLessons.contains(lesson.id);
      }
    }
  }

  bool _isOfflineTestSession() {
    return OfflineTestMode.isActive();
  }
}
