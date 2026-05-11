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
      type: model.type,
      isCompleted: model.isCompleted,
      youtubeVideoId: model.youtubeVideoId,
    );
  }

  static Lesson fromDomain(LessonEntity entity) {
    return Lesson(
      id: entity.id,
      courseId: entity.courseId,
      title: entity.title,
      content: entity.content,
      duration: entity.duration,
      type: entity.type,
      isCompleted: entity.isCompleted,
      youtubeVideoId: entity.youtubeVideoId,
    );
  }
}
