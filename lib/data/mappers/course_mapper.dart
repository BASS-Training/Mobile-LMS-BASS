import '../../domain/entities/course_entity.dart';
import '../models/course.dart';
import 'lesson_mapper.dart';

class CourseMapper {
  static CourseEntity toDomain(Course model) {
    // Flatten all lessons from all sections
    final allLessons = model.lessons;
    
    return CourseEntity(
      id: model.id,
      title: model.title,
      description: model.description,
      instructor: model.instructor,
      color: model.color,
      icon: model.icon,
      chaptersCount: model.chaptersCount,
      duration: model.duration,
      lessons: allLessons.map((l) => LessonMapper.toDomain(l)).toList(),
      isSaved: model.isSaved,
    );
  }

  static Course fromDomain(CourseEntity entity) {
    // For now, just reconstruct with empty sections since entity doesn't have section info
    // This is a simplified approach for backward compatibility
    return Course(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      instructor: entity.instructor,
      color: entity.color,
      icon: entity.icon,
      chaptersCount: entity.chaptersCount,
      duration: entity.duration,
      sections: [],
      isSaved: entity.isSaved,
    );
  }
}
