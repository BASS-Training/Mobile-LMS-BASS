import 'package:lms_mobile_app/src/features/lessons/data/mappers/lesson_mapper.dart';

import '../../domain/entities/course_entity.dart';
import '../../domain/entities/course_section_entity.dart';
import '../models/course.dart';
import '../models/course_section.dart';

class CourseMapper {
  static CourseEntity toDomain(Course model) {
    final sections = model.sections
        .map(
          (section) => CourseSectionEntity(
            id: section.id,
            courseId: section.courseId,
            sectionNumber: section.sectionNumber,
            title: section.title,
            description: section.description,
            lessons: section.lessons
                .map((lesson) => LessonMapper.toDomain(lesson))
                .toList(),
          ),
        )
        .toList();

    final allLessons = sections.expand((section) => section.lessons).toList();

    return CourseEntity(
      id: model.id,
      title: model.title,
      description: model.description,
      instructor: model.instructor,
      color: model.color,
      icon: model.icon,
      thumbnailUrl: model.thumbnailUrl,
      chaptersCount: model.chaptersCount,
      duration: model.duration,
      sections: sections,
      lessons: allLessons,
      isSaved: model.isSaved,
      isOwned: model.isOwned,
    );
  }

  static Course fromDomain(CourseEntity entity) {
    final sections = entity.sections
        .map(
          (section) => CourseSection(
            id: section.id,
            courseId: section.courseId,
            sectionNumber: section.sectionNumber,
            title: section.title,
            description: section.description,
            lessons: section.lessons
                .map((lesson) => LessonMapper.fromDomain(lesson))
                .toList(),
          ),
        )
        .toList();

    return Course(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      instructor: entity.instructor,
      color: entity.color,
      icon: entity.icon,
      thumbnailUrl: entity.thumbnailUrl,
      chaptersCount: entity.chaptersCount,
      duration: entity.duration,
      sections: sections,
      isSaved: entity.isSaved,
      isOwned: entity.isOwned,
    );
  }
}
