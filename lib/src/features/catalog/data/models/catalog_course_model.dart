import '../../domain/entities/catalog_course_entity.dart';
import '../../domain/entities/course_sales_profile.dart';

/// Model katalog yang mentolerir dua bentuk JSON:
/// - Respons API (camelCase): `shortDescription`, `lessonsCount`, `thumbnailUrl`,
///   `isFree`, `isPaid`, `price`, `priceLabel`, `isEnrolled`.
/// - Asset fallback lokal (snake_case): `description`, `lesson_count`,
///   `thumbnail_url`, `access_type`.
///
/// Field yang tidak dikenal (mis. `duration` lama, `meta`) diabaikan agar
/// penambahan field di server tidak merusak parsing.
class CatalogCourseModel {
  final String id;
  final String title;
  final String description;
  final String shortDescription;
  final String instructor;
  final String? thumbnailUrl;
  final int lessonCount;
  final bool isFree;
  final bool isPaid;
  final num? price;
  final String priceLabel;
  final List<CatalogSectionEntity> sections;
  final int? totalContents;
  final bool isEnrolled;
  final CourseSalesProfile? salesProfile;
  final List<CatalogInstructor> instructors;
  final bool showPrice;

  const CatalogCourseModel({
    required this.id,
    required this.title,
    required this.description,
    this.shortDescription = '',
    required this.instructor,
    required this.lessonCount,
    required this.isFree,
    required this.isPaid,
    required this.priceLabel,
    this.thumbnailUrl,
    this.price,
    this.sections = const [],
    this.totalContents,
    this.isEnrolled = false,
    this.salesProfile,
    this.instructors = const [],
    this.showPrice = false,
  });

  factory CatalogCourseModel.fromJson(Map<String, dynamic> json) {
    final rawAccessType = json['access_type']?.toString();
    final isFree = json['isFree'] is bool
        ? json['isFree'] as bool
        : rawAccessType != 'external';
    final isPaid = json['isPaid'] is bool
        ? json['isPaid'] as bool
        : rawAccessType == 'external';

    // List endpoint hanya mengirim `shortDescription`; detail endpoint mengirim
    // `description` (boleh HTML). Utamakan `description` bila tersedia.
    final description = _firstNonEmpty([
      json['description'],
      json['shortDescription'],
    ]);
    final rawPriceLabel = json['priceLabel']?.toString().trim();
    final thumbnail = _firstNonEmpty([
      json['thumbnailUrl'],
      json['thumbnail_url'],
    ]);

    return CatalogCourseModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: description,
      shortDescription: _firstNonEmpty([json['shortDescription']]),
      instructor: json['instructor']?.toString() ?? '',
      thumbnailUrl: thumbnail.isEmpty ? null : thumbnail,
      lessonCount: _asInt(json['lessonsCount'] ?? json['lesson_count']),
      isFree: isFree,
      isPaid: isPaid,
      price: _asNum(json['price']),
      priceLabel: (rawPriceLabel == null || rawPriceLabel.isEmpty)
          ? (isFree ? 'Gratis' : 'Berbayar')
          : rawPriceLabel,
      sections: _parseSections(json['sections']),
      totalContents: json['totalContents'] == null
          ? null
          : _asInt(json['totalContents']),
      isEnrolled: json['isEnrolled'] is bool
          ? json['isEnrolled'] as bool
          : false,
      salesProfile: _parseSalesProfile(json['salesProfile']),
      instructors: _parseInstructors(json['instructors']),
      showPrice: json['showPrice'] == true,
    );
  }

  CatalogCourseEntity toEntity() {
    return CatalogCourseEntity(
      id: id,
      title: title,
      description: description,
      shortDescription: shortDescription,
      instructor: instructor,
      thumbnailUrl: thumbnailUrl,
      lessonCount: lessonCount,
      isFree: isFree,
      isPaid: isPaid,
      price: price,
      priceLabel: priceLabel,
      sections: sections,
      totalContents: totalContents,
      isEnrolled: isEnrolled,
      salesProfile: salesProfile,
      instructors: instructors,
      showPrice: showPrice,
    );
  }

  /// Salin model dengan status keanggotaan baru (dipakai repository untuk
  /// menerapkan hasil pendaftaran / data enrollment lokal).
  CatalogCourseModel withEnrolled(bool value) {
    return CatalogCourseModel(
      id: id,
      title: title,
      description: description,
      shortDescription: shortDescription,
      instructor: instructor,
      thumbnailUrl: thumbnailUrl,
      lessonCount: lessonCount,
      isFree: isFree,
      isPaid: isPaid,
      price: price,
      priceLabel: priceLabel,
      sections: sections,
      totalContents: totalContents,
      isEnrolled: value,
      salesProfile: salesProfile,
      instructors: instructors,
      showPrice: showPrice,
    );
  }

  static CourseSalesProfile? _parseSalesProfile(dynamic raw) {
    if (raw is! Map) return null;
    final faq = raw['faq'];
    return CourseSalesProfile(
      headline: _nullableText(raw['headline']),
      targetAudience: _nullableText(raw['targetAudience']),
      learningBenefits: _nullableText(raw['learningBenefits']),
      requirements: _nullableText(raw['requirements']),
      level: _nullableText(raw['level']),
      estimatedDurationMinutes: raw['estimatedDurationMinutes'] == null
          ? null
          : _asInt(raw['estimatedDurationMinutes']),
      language: _nullableText(raw['language']),
      promoVideoUrl: _nullableText(raw['promoVideoUrl']),
      faq: faq is List
          ? faq
                .whereType<Map>()
                .map(
                  (item) => CourseSalesFaq(
                    question: _firstNonEmpty([item['question']]),
                    answer: _firstNonEmpty([item['answer']]),
                  ),
                )
                .where(
                  (item) => item.question.isNotEmpty && item.answer.isNotEmpty,
                )
                .toList()
          : const [],
    );
  }

  static List<CatalogInstructor> _parseInstructors(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (item) => CatalogInstructor(
            id: item['id']?.toString() ?? '',
            name: _firstNonEmpty([item['name']]),
            avatarUrl: _nullableText(item['avatarUrl']),
            bioHtml: _nullableText(item['bioHtml']),
          ),
        )
        .where((item) => item.name.isNotEmpty)
        .toList();
  }

  static String? _nullableText(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static List<CatalogSectionEntity> _parseSections(dynamic rawSections) {
    if (rawSections is! List) return const [];

    return rawSections.whereType<Map>().map((section) {
      final lessons = section['lessons'];
      return CatalogSectionEntity(
        title: section['title']?.toString() ?? '',
        // Detail API: jumlah dari daftar `lessons`.
        // Fallback lokal: jumlah langsung dari `lesson_count`.
        lessonCount: lessons is List
            ? lessons.length
            : _asInt(section['lesson_count']),
      );
    }).toList();
  }

  static String _firstNonEmpty(List<dynamic> candidates) {
    for (final candidate in candidates) {
      final value = candidate?.toString().trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return '';
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static num? _asNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    return num.tryParse(value.toString());
  }
}
