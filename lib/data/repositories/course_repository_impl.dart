import '../../domain/entities/course_entity.dart';
import '../../domain/repositories/course_repository.dart';
import '../mappers/course_mapper.dart';
import '../models/course.dart';
import '../sources/dummy_data.dart';
import '../sources/local_storage.dart';

class CourseRepositoryImpl implements CourseRepository {
  List<Course> _courses = [];

  @override
  Future<List<CourseEntity>> getCourses() async {
    _courses = DummyData.getCourses();
    _updateCompletionStatus();
    return _courses.map((c) => CourseMapper.toDomain(c)).toList();
  }

  @override
  Future<CourseEntity?> getCourseById(String id) async {
    try {
      final course = _courses.firstWhere((course) => course.id == id);
      return CourseMapper.toDomain(course);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<CourseEntity>> searchCourses(String query) async {
    if (_courses.isEmpty) {
      await getCourses();
    }
    
    final filtered = _courses
        .where(
          (course) =>
              course.title.toLowerCase().contains(query.toLowerCase()) ||
              course.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return filtered.map((c) => CourseMapper.toDomain(c)).toList();
  }

  @override
  Future<void> toggleSaveCourse(String courseId) async {
    final courseIndex = _courses.indexWhere((c) => c.id == courseId);
    if (courseIndex != -1) {
      _courses[courseIndex].isSaved = !_courses[courseIndex].isSaved;
    }
  }

  @override
  Future<List<CourseEntity>> getSavedCourses() async {
    if (_courses.isEmpty) {
      await getCourses();
    }
    
    return _courses
        .where((c) => c.isSaved)
        .map((c) => CourseMapper.toDomain(c))
        .toList();
  }

  @override
  Future<void> refreshCourses() async {
    _updateCompletionStatus();
  }

  void _updateCompletionStatus() {
    final completedLessons = LocalStorage.getCompletedLessons();
    for (var course in _courses) {
      for (var lesson in course.lessons) {
        lesson.isCompleted = completedLessons.contains(lesson.id);
      }
    }
  }
}
