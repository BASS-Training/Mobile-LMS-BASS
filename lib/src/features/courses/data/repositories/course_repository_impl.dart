import 'package:lms_mobile_app/src/core/utils/local_storage.dart';

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
    try {
      // Strategi: Coba remote dulu untuk data terbaru
      final remoteCourses = await remoteDataSource.getCourses();
      // Simpan ke cache local
      await localDataSource.saveCourses(remoteCourses);
      _updateCompletionStatus(remoteCourses);
      return _mapCoursesToEntities(remoteCourses);
    } catch (e) {
      // Fallback ke local cache jika remote gagal
      final localCourses = await localDataSource.getCourses();
      _updateCompletionStatus(localCourses);
      return _mapCoursesToEntities(localCourses);
    }
  }

  @override
  Future<CourseEntity?> getCourseById(String id) async {
    try {
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
    try {
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
  Future<List<CourseEntity>> getSavedCourses() async {
    try {
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
}
