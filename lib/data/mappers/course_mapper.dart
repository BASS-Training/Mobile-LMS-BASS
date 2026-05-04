import '../../domain/entities/course_entity.dart';
import '../models/course.dart';
import 'lesson_mapper.dart';

class CourseMapper {
  static CourseEntity toDomain(Course model) {
    return CourseEntity(
      id: model.id,
      title: model.title,
      description: model.description,
      instructor: model.instructor,
      color: model.color,
      icon: model.icon,
      chaptersCount: model.chaptersCount,
      duration: model.duration,
      lessons: model.lessons.map((l) => LessonMapper.toDomain(l)).toList(),
      isSaved: model.isSaved,
    );
  }

  static Course fromDomain(CourseEntity entity) {
    return Course(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      instructor: entity.instructor,
      color: entity.color,
      icon: entity.icon,
      chaptersCount: entity.chaptersCount,
      duration: entity.duration,
      lessons: entity.lessons.map((l) => LessonMapper.fromDomain(l)).toList(),
      isSaved: entity.isSaved,
    );
  }
}
