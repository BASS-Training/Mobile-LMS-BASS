import 'package:equatable/equatable.dart';

import 'lesson_entity.dart';

class CourseSectionEntity extends Equatable {
  final String id;
  final String courseId;
  final int sectionNumber;
  final String title;
  final String description;
  final List<LessonEntity> lessons;

  const CourseSectionEntity({
    required this.id,
    required this.courseId,
    required this.sectionNumber,
    required this.title,
    required this.description,
    required this.lessons,
  });

  int get completedLessons {
    var count = 0;
    for (final lesson in lessons) {
      if (lesson.isCompleted) {
        count++;
      }
    }
    return count;
  }
  int get totalLessons => lessons.length;
  double get progressPercentage =>
      totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;

  CourseSectionEntity copyWith({
    String? id,
    String? courseId,
    int? sectionNumber,
    String? title,
    String? description,
    List<LessonEntity>? lessons,
  }) {
    return CourseSectionEntity(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      lessons: lessons ?? this.lessons,
    );
  }

  @override
  List<Object?> get props => [id, courseId, sectionNumber, title, description, lessons];
}