import '../../domain/entities/document_section_entity.dart';

class DocumentSectionModel extends DocumentSectionEntity {
  DocumentSectionModel({
    required super.title,
    required super.paragraphs,
    required super.bullets,
  });

  // Nanti fungsi ini akan berguna saat integrasi API sungguhan
  factory DocumentSectionModel.fromJson(Map<String, dynamic> json) {
    return DocumentSectionModel(
      title: json['title'] ?? '',
      paragraphs: List<String>.from(json['paragraphs'] ?? []),
      bullets: List<String>.from(json['bullets'] ?? []),
    );
  }
}