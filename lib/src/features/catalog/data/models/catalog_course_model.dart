/// DTO etalase (JSON ⇆ Dart) untuk `/mobile/catalog`.
///
/// Semua parsing dibuat defensif (`?? ` + cast aman) karena payload katalog
/// tumbuh seiring fitur toko di web; field baru tidak boleh membuat mobile
/// lama crash.
class CatalogCourseModel {
  final String id;
  final String title;
  final String shortDescription;
  final String description;
  final String instructor;
  final String? thumbnailUrl;
  final int lessonsCount;
  final int totalContents;
  final bool isFree;
  final int? price;
  final String priceLabel;
  final bool isEnrolled;
  final List<CatalogSectionModel> sections;

  const CatalogCourseModel({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.description,
    required this.instructor,
    required this.thumbnailUrl,
    required this.lessonsCount,
    required this.totalContents,
    required this.isFree,
    required this.price,
    required this.priceLabel,
    required this.isEnrolled,
    required this.sections,
  });

  factory CatalogCourseModel.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'];

    return CatalogCourseModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      shortDescription: json['shortDescription']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      instructor: json['instructor']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      lessonsCount: _toInt(json['lessonsCount']),
      totalContents: _toInt(json['totalContents']),
      isFree: json['isFree'] == true,
      price: json['price'] == null ? null : _toInt(json['price']),
      priceLabel: json['priceLabel']?.toString() ?? '',
      isEnrolled: json['isEnrolled'] == true,
      sections: rawSections is List
          ? rawSections
                .whereType<Map>()
                .map(
                  (e) => CatalogSectionModel.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class CatalogSectionModel {
  final String id;
  final int sectionNumber;
  final String title;
  final List<CatalogLessonModel> lessons;

  const CatalogSectionModel({
    required this.id,
    required this.sectionNumber,
    required this.title,
    required this.lessons,
  });

  factory CatalogSectionModel.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessons'];

    return CatalogSectionModel(
      id: json['id']?.toString() ?? '',
      sectionNumber: _toInt(json['sectionNumber']),
      title: json['title']?.toString() ?? '',
      lessons: rawLessons is List
          ? rawLessons
                .whereType<Map>()
                .map(
                  (e) =>
                      CatalogLessonModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : const [],
    );
  }
}

class CatalogLessonModel {
  final String id;
  final String title;
  final String type;

  const CatalogLessonModel({
    required this.id,
    required this.title,
    required this.type,
  });

  factory CatalogLessonModel.fromJson(Map<String, dynamic> json) {
    return CatalogLessonModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
