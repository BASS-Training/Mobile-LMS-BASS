import '../../domain/entities/lesson_entity.dart';
import '../models/lesson.dart';

class LessonMapper {
  static LessonEntity toDomain(Lesson model) {
    return LessonEntity(
      id: model.id,
      courseId: model.courseId,
      title: model.title,
      content: model.content,
      duration: model.duration,
      isCompleted: model.isCompleted,
    );
  }

  static Lesson fromDomain(LessonEntity entity) {
    return Lesson(
      id: entity.id,
      courseId: entity.courseId,
      title: entity.title,
      content: entity.content,
      duration: entity.duration,
      isCompleted: entity.isCompleted,
    );
  }
}
