import 'package:equatable/equatable.dart';

class LessonEntity extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final String duration;
  final bool isCompleted;

  const LessonEntity({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.duration,
    this.isCompleted = false,
  });

  LessonEntity copyWith({bool? isCompleted}) {
    return LessonEntity(
      id: id,
      courseId: courseId,
      title: title,
      content: content,
      duration: duration,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, courseId, title, content, duration, isCompleted];
}
