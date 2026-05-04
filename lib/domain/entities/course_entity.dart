import 'package:equatable/equatable.dart';
import 'lesson_entity.dart';

class CourseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String color;
  final String icon;
  final int chaptersCount;
  final String duration;
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
    required this.lessons,
    this.isSaved = false,
  });

  int get completedLessons => lessons.where((l) => l.isCompleted).length;
  int get totalLessons => lessons.length;
  double get progressPercentage =>
      totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;

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
      lessons: lessons,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [id, title, description, instructor, color, icon, chaptersCount, duration, lessons, isSaved];
}
