import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:lms_mobile_app/src/features/courses/data/datasources/course_local_data_source.dart';
import 'package:lms_mobile_app/src/features/courses/data/datasources/course_remote_data_source.dart';
import 'package:lms_mobile_app/src/features/courses/data/models/course.dart';
import 'package:lms_mobile_app/src/features/courses/data/repositories/course_repository_impl.dart';

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory = await Directory.systemTemp.createTemp('course_repository_');
    Hive.init(hiveDirectory.path);
    await Hive.openBox('mini_lms_box');
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test('getSavedCourses tidak mengganti cache daftar course utama', () async {
    final allCourses = [_course('course-1'), _course('course-2')];
    final localDataSource = _FakeCourseLocalDataSource(allCourses);
    final repository = CourseRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: _FakeCourseRemoteDataSource([
        _course('course-1', isSaved: true),
      ]),
    );

    final savedCourses = await repository.getSavedCourses();

    expect(savedCourses.map((course) => course.id), ['course-1']);
    expect((await localDataSource.getCourses()).map((course) => course.id), [
      'course-1',
      'course-2',
    ]);
    expect(localDataSource.saveCoursesCalls, 0);
  });
}

Course _course(String id, {bool isSaved = false}) {
  return Course(
    id: id,
    title: id,
    description: '',
    instructor: '',
    color: '#000000',
    icon: '',
    chaptersCount: 0,
    duration: '',
    sections: const [],
    isSaved: isSaved,
  );
}

class _FakeCourseLocalDataSource implements CourseLocalDataSource {
  List<Course> courses;
  int saveCoursesCalls = 0;

  _FakeCourseLocalDataSource(List<Course> courses) : courses = [...courses];

  @override
  Future<void> clearCourses() async => courses.clear();

  @override
  Future<Course?> getCourseById(String id) async {
    for (final course in courses) {
      if (course.id == id) return course;
    }
    return null;
  }

  @override
  Future<List<Course>> getCourses() async => courses;

  @override
  Future<void> saveCourse(Course course) async {
    final index = courses.indexWhere((item) => item.id == course.id);
    if (index == -1) {
      courses.add(course);
    } else {
      courses[index] = course;
    }
  }

  @override
  Future<void> saveCourses(List<Course> courses) async {
    saveCoursesCalls++;
    this.courses = [...courses];
  }

  @override
  Future<void> toggleSaveCourse(String courseId) async {}
}

class _FakeCourseRemoteDataSource implements CourseRemoteDataSource {
  final List<Course> savedCourses;

  _FakeCourseRemoteDataSource(this.savedCourses);

  @override
  Future<void> addCourse(Course course) => throw UnimplementedError();

  @override
  Future<Course?> getCourseById(String id) => throw UnimplementedError();

  @override
  Future<List<Course>> getCourses() => throw UnimplementedError();

  @override
  Future<List<Course>> getSavedCourses() async => savedCourses;

  @override
  Future<void> toggleSaveCourse(String courseId) => throw UnimplementedError();
}
