import '../../domain/entities/text_section_entity.dart';

class TextSectionModel extends TextSectionEntity {
  TextSectionModel({
    required super.title,
    required super.paragraphs,
    required super.bullets,
  });

  // Nanti fungsi ini akan berguna saat integrasi API sungguhan
  factory TextSectionModel.fromJson(Map<String, dynamic> json) {
    return TextSectionModel(
      title: json['title'] ?? '',
      paragraphs: List<String>.from(json['paragraphs'] ?? []),
      bullets: List<String>.from(json['bullets'] ?? []),
    );
  }
}
