import 'package:equatable/equatable.dart';
import 'lesson_entity.dart';
import 'course_section_entity.dart';
import '../value_objects/progress.dart';

class CourseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String color;
  final String icon;
  final int chaptersCount;
  final String duration;
  final List<CourseSectionEntity> sections;
  final List<LessonEntity> lessons;
  final bool isSaved;

  const CourseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.color,
    required this.icon,
    required this.chaptersCount,
    required this.duration,
    required this.sections,
    required this.lessons,
    this.isSaved = false,
  });

  List<LessonEntity> get allLessons => sections.isNotEmpty
      ? sections.expand((section) => section.lessons).toList()
      : lessons;

  /// Get progress value object (source of truth untuk progress calculation)
  Progress get progress {
    final completedCount = allLessons
        .where((lesson) => lesson.isCompleted)
        .length;
    final totalCount = allLessons.length;
    return Progress.create(
      completedCount: completedCount,
      totalCount: totalCount,
    );
  }

  /// Convenience getters untuk backward compatibility
  int get completedLessons => progress.completedCount;
  int get totalLessons => progress.totalCount;
  double get progressPercentage => progress.percentage;

  CourseEntity copyWith({bool? isSaved}) {
    return CourseEntity(
      id: id,
      title: title,
      description: description,
      instructor: instructor,
      color: color,
      icon: icon,
      chaptersCount: chaptersCount,
      duration: duration,
      sections: sections,
      lessons: lessons,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    instructor,
    color,
    icon,
    chaptersCount,
    duration,
    sections,
    lessons,
    isSaved,
  ];
}
