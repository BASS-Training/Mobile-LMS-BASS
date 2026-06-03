import 'package:equatable/equatable.dart';
import 'package:lms_mobile_app/src/features/courses/domain/value_objects/progress.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_entity.dart';
import 'course_section_entity.dart';

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

  /// Whether the current user owns / is enrolled in this course.
  ///
  /// Owned courses are fully accessible; unowned ("catalog") courses are shown
  /// as a locked preview that points the learner to purchase on the web.
  /// Defaults to `true` so existing behaviour (the API only returns the user's
  /// own courses) is unchanged until the backend exposes an enrollment flag.
  final bool isOwned;

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
    this.isOwned = true,
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

  /// Logika Bisnis: Menentukan apakah materi terbuka atau terkunci
  bool isLessonUnlocked(LessonEntity lesson) {
    final lessonIndex = allLessons.indexOf(lesson);

    // Lesson pertama selalu terbuka
    if (lessonIndex <= 0) return true;

    // Cek apakah lesson sebelumnya sudah selesai
    final previousLesson = allLessons[lessonIndex - 1];
    return previousLesson.isCompleted;
  }

  CourseEntity copyWith({bool? isSaved, bool? isOwned}) {
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
      isOwned: isOwned ?? this.isOwned,
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
    isOwned,
  ];
}
