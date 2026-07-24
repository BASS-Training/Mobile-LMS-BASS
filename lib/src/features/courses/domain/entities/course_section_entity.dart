import 'package:equatable/equatable.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import '../value_objects/progress.dart';

class CourseSectionEntity extends Equatable {
  final String id;
  final String courseId;
  final int sectionNumber;
  final String title;
  final String description;
  final List<LessonEntity> lessons;

  /// Id section yang harus diselesaikan sebelum section ini terbuka. `null`
  /// berarti tanpa prasyarat. Dipakai [CourseEntity.isLessonUnlocked].
  final String? prerequisiteId;

  /// Bila section ini dijadikan prasyarat section lain, `true` berarti boleh
  /// dilewati (tidak menahan section yang menjadikannya prasyarat).
  final bool isOptional;

  const CourseSectionEntity({
    required this.id,
    required this.courseId,
    required this.sectionNumber,
    required this.title,
    required this.description,
    required this.lessons,
    this.prerequisiteId,
    this.isOptional = false,
  });

  /// Get progress value object (source of truth untuk progress calculation)
  Progress get progress {
    final completedCount = lessons.where((lesson) => lesson.isCompleted).length;
    final totalCount = lessons.length;
    return Progress.create(
      completedCount: completedCount,
      totalCount: totalCount,
    );
  }

  /// Convenience getters untuk backward compatibility
  int get completedLessons => progress.completedCount;
  int get totalLessons => progress.totalCount;
  double get progressPercentage => progress.percentage;
  bool get isFullyCompleted => progress.isFullyCompleted;

  CourseSectionEntity copyWith({
    String? id,
    String? courseId,
    int? sectionNumber,
    String? title,
    String? description,
    List<LessonEntity>? lessons,
    String? prerequisiteId,
    bool? isOptional,
  }) {
    return CourseSectionEntity(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      sectionNumber: sectionNumber ?? this.sectionNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      lessons: lessons ?? this.lessons,
      prerequisiteId: prerequisiteId ?? this.prerequisiteId,
      isOptional: isOptional ?? this.isOptional,
    );
  }

  @override
  List<Object?> get props => [
    id,
    courseId,
    sectionNumber,
    title,
    description,
    lessons,
    prerequisiteId,
    isOptional,
  ];
}
