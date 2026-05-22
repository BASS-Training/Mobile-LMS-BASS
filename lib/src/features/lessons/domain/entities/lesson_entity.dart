import 'package:equatable/equatable.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/text_section_entity.dart';

class LessonEntity extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final String duration;
  final String type;
  final bool isCompleted;
  final String? youtubeVideoId;
  final List<TextSectionEntity>? textSections;

  const LessonEntity({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.duration,
    this.type = 'text',
    this.isCompleted = false,
    this.youtubeVideoId,
    this.textSections,
  });

  bool get hasVideo => type == 'video' && (youtubeVideoId?.isNotEmpty ?? false);

  LessonEntity copyWith({
    bool? isCompleted,
    String? type,
    String? youtubeVideoId,
    List<TextSectionEntity>? textSections,
  }) {
    return LessonEntity(
      id: id,
      courseId: courseId,
      title: title,
      content: content,
      duration: duration,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      textSections: textSections ?? this.textSections,
    );
  }

  @override
  List<Object?> get props => [
    id,
    courseId,
    title,
    content,
    duration,
    type,
    isCompleted,
    youtubeVideoId,
    textSections,
  ];
}
