import 'package:equatable/equatable.dart';
import 'package:lms_mobile_app/domain/entities/document_section_entity.dart';

class LessonEntity extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final String duration;
  final String type;
  final bool isCompleted;
  final String? youtubeVideoId;
  final List<DocumentSectionEntity>? documentSections;

  const LessonEntity({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.duration,
    this.type = 'document',
    this.isCompleted = false,
    this.youtubeVideoId,
    this.documentSections,
  });

  LessonEntity copyWith({
    bool? isCompleted,
    String? type,
    String? youtubeVideoId,
    List<DocumentSectionEntity>? documentSections,
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
      documentSections: documentSections ?? this.documentSections,
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
    documentSections,
  ];
}
