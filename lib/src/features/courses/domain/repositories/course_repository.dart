import '../entities/course_entity.dart';

abstract class CourseRepository {
  Future<List<CourseEntity>> getCourses();
  Stream<List<CourseEntity>> watchCourses();
  Future<void> addCourse(CourseEntity course);
  Future<CourseEntity?> getCourseById(String id);
  Future<List<CourseEntity>> searchCourses(String query);
  Future<void> toggleSaveCourse(String courseId);
  Future<List<CourseEntity>> getSavedCourses();
  Future<void> refreshCourses();
}
