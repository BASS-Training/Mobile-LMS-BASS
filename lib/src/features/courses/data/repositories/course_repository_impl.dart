import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/core/utils/app_logger.dart';
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
      logDebug(
        '[COURSE][FETCH] using local dummy getCourses tester=${OfflineTestMode.describeContext()}',
      );
      final localCourses = await localDataSource.getCourses();
      await _reconcileCompletionStatus(localCourses);
      return _mapCoursesToEntities(localCourses);
    }

    try {
      logDebug(
        '[COURSE][FETCH] using remote API getCourses tester=${OfflineTestMode.describeContext()}',
      );
      // Strategi: Coba remote dulu untuk data terbaru
      final remoteCourses = await remoteDataSource.getCourses();
      // Simpan ke cache local
      await localDataSource.saveCourses(remoteCourses);
      await _reconcileCompletionStatus(remoteCourses);
      return _mapCoursesToEntities(remoteCourses);
    } catch (e) {
      // Fallback ke local cache jika remote gagal
      logDebug("===== ERROR DARI LARAVEL: $e =====");
      final localCourses = await localDataSource.getCourses();
      await _reconcileCompletionStatus(localCourses);
      return _mapCoursesToEntities(localCourses);
    }
  }

  @override
  Future<List<CourseEntity>> getCachedCourses() async {
    if (_isOfflineTestSession()) return [];

    final raw = LocalStorage.getCoursesCache();
    if (raw == null || raw.isEmpty) return [];

    try {
      final courses = raw
          .map((j) => Course.fromJson(Map<String, dynamic>.from(j)))
          .toList();
      await _reconcileCompletionStatus(courses);
      return _mapCoursesToEntities(courses);
    } catch (e) {
      logDebug('[COURSE][CACHE] gagal membaca cache course: $e');
      return [];
    }
  }

  @override
  Stream<List<CourseEntity>> watchCourses() async* {
    if (_isOfflineTestSession()) {
      logDebug(
        '[COURSE][WATCH] using local dummy watchCourses tester=${OfflineTestMode.describeContext()}',
      );
      final localCourses = await localDataSource.getCourses();
      await _reconcileCompletionStatus(localCourses);
      yield _mapCoursesToEntities(localCourses);
      return;
    }

    // Cache-first: pancarkan cache disk lebih dulu (instan) bila ada, lalu
    // lanjut dengan data segar dari jaringan.
    final cached = await getCachedCourses();
    if (cached.isNotEmpty) {
      yield cached;
    }

    logDebug(
      '[COURSE][WATCH] using remote API watchCourses tester=${OfflineTestMode.describeContext()}',
    );
    await for (final courses in remoteDataSource.watchCourses()) {
      await _reconcileCompletionStatus(courses);
      yield _mapCoursesToEntities(courses);
    }
  }

  @override
  Future<CourseEntity?> getCourseById(String id) async {
    if (_isOfflineTestSession()) {
      logDebug(
        '[COURSE][DETAIL] using local dummy getCourseById id=$id tester=${OfflineTestMode.describeContext()}',
      );
      final localCourse = await localDataSource.getCourseById(id);
      if (localCourse != null) {
        await _reconcileCompletionStatus([localCourse]);
        return CourseMapper.toDomain(localCourse);
      }
      return null;
    }

    try {
      logDebug(
        '[COURSE][DETAIL] using remote API getCourseById id=$id tester=${OfflineTestMode.describeContext()}',
      );
      // Coba remote dulu
      final remoteCourse = await remoteDataSource.getCourseById(id);
      if (remoteCourse != null) {
        // Simpan ke cache
        await localDataSource.saveCourse(remoteCourse);
        await _reconcileCompletionStatus([remoteCourse]);
        return CourseMapper.toDomain(remoteCourse);
      }
    } catch (e) {
      // Fallback ke local
    }

    // Jika remote gagal atau return null, cek local
    final localCourse = await localDataSource.getCourseById(id);
    if (localCourse != null) {
      await _reconcileCompletionStatus([localCourse]);
      return CourseMapper.toDomain(localCourse);
    }

    return null;
  }

  @override
  Future<List<CourseEntity>> searchCourses(String query) async {
    if (_isOfflineTestSession()) {
      logDebug(
        '[COURSE][SEARCH] using local dummy searchCourses query=$query tester=${OfflineTestMode.describeContext()}',
      );
      final localCourses = await localDataSource.searchCourses(query);
      await _reconcileCompletionStatus(localCourses);
      return _mapCoursesToEntities(localCourses);
    }

    try {
      logDebug(
        '[COURSE][SEARCH] using remote API searchCourses query=$query tester=${OfflineTestMode.describeContext()}',
      );
      // Coba remote dulu
      final remoteCourses = await remoteDataSource.searchCourses(query);
      // Simpan ke cache
      await localDataSource.saveCourses(remoteCourses);
      await _reconcileCompletionStatus(remoteCourses);
      return _mapCoursesToEntities(remoteCourses);
    } catch (e) {
      // Fallback ke local cache
      final localCourses = await localDataSource.searchCourses(query);
      await _reconcileCompletionStatus(localCourses);
      return _mapCoursesToEntities(localCourses);
    }
  }

  @override
  Future<void> toggleSaveCourse(String courseId) async {
    // Sesi tester offline: cukup simpan di cache lokal.
    if (_isOfflineTestSession()) {
      await localDataSource.toggleSaveCourse(courseId);
      return;
    }

    // Persist ke backend dulu (sumber kebenaran, melekat ke akun). Jika gagal,
    // error dilempar agar BLoC bisa membatalkan update optimistik di UI.
    await remoteDataSource.toggleSaveCourse(courseId);

    // Sinkronkan cache lokal supaya pembacaan berikutnya konsisten.
    await localDataSource.toggleSaveCourse(courseId);
  }

  @override
  Future<void> addCourse(CourseEntity course) async {
    final model = CourseMapper.fromDomain(course);
    if (_isOfflineTestSession()) {
      logDebug(
        '[COURSE][ADD] using local dummy addCourse id=${course.id} tester=${OfflineTestMode.describeContext()}',
      );
      await localDataSource.saveCourse(model);
      return;
    }

    logDebug(
      '[COURSE][ADD] using remote API addCourse id=${course.id} tester=${OfflineTestMode.describeContext()}',
    );
    await remoteDataSource.addCourse(model);
    await localDataSource.saveCourse(model);
  }

  @override
  Future<List<CourseEntity>> getSavedCourses() async {
    if (_isOfflineTestSession()) {
      logDebug(
        '[COURSE][SAVED] using local dummy getSavedCourses tester=${OfflineTestMode.describeContext()}',
      );
      final localCourses = await localDataSource.getCourses();
      final savedCourses = localCourses.where((c) => c.isSaved).toList();
      await _reconcileCompletionStatus(savedCourses);
      return _mapCoursesToEntities(savedCourses);
    }

    try {
      logDebug(
        '[COURSE][SAVED] using remote API getSavedCourses tester=${OfflineTestMode.describeContext()}',
      );
      // Coba remote dulu untuk list terbaru
      final remoteSavedCourses = await remoteDataSource.getSavedCourses();
      // Simpan ke cache
      await localDataSource.saveCourses(remoteSavedCourses);
      await _reconcileCompletionStatus(remoteSavedCourses);
      return _mapCoursesToEntities(remoteSavedCourses);
    } catch (e) {
      // Fallback ke local cache
      final localCourses = await localDataSource.getCourses();
      final savedCourses = localCourses.where((c) => c.isSaved).toList();
      await _reconcileCompletionStatus(savedCourses);
      return _mapCoursesToEntities(savedCourses);
    }
  }

  @override
  Future<void> refreshCourses() async {
    if (_isOfflineTestSession()) {
      logDebug(
        '[COURSE][REFRESH] using local dummy refreshCourses tester=${OfflineTestMode.describeContext()}',
      );
      final localCourses = await localDataSource.getCourses();
      await _reconcileCompletionStatus(localCourses);
      return;
    }

    logDebug(
      '[COURSE][REFRESH] using remote API refreshCourses tester=${OfflineTestMode.describeContext()}',
    );
    // Refresh akan coba remote dulu, fallback ke local
    try {
      final remoteCourses = await remoteDataSource.getCourses();
      await localDataSource.saveCourses(remoteCourses);
      await _reconcileCompletionStatus(remoteCourses);
    } catch (e) {
      // Jika remote gagal, biarkan pakai cache yang ada
      final localCourses = await localDataSource.getCourses();
      await _reconcileCompletionStatus(localCourses);
    }
  }

  /// Map list of courses ke list of entities
  List<CourseEntity> _mapCoursesToEntities(List<Course> courses) {
    return courses.map((c) => CourseMapper.toDomain(c)).toList();
  }

  /// Reconcile completion status between server data and local cache.
  /// Server state wins, but local completions are preserved if the server is
  /// temporarily behind.
  Future<void> _reconcileCompletionStatus(List<Course> courses) async {
    final completedLessons = LocalStorage.getCompletedLessons().toSet();

    for (final course in courses) {
      for (final lesson in course.lessons) {
        final serverCompleted = lesson.isCompleted;
        final localCompleted = completedLessons.contains(lesson.id);
        final completed = serverCompleted || localCompleted;

        lesson.isCompleted = completed;

        if (completed && !localCompleted) {
          await LocalStorage.markLessonComplete(lesson.id);
          completedLessons.add(lesson.id);
        }
      }
    }
  }

  bool _isOfflineTestSession() {
    return OfflineTestMode.isActive();
  }
}