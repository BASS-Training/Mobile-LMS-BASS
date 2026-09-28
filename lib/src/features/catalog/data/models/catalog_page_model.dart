import '../../domain/entities/catalog_page_entity.dart';
import 'catalog_course_model.dart';

/// Hasil satu request `GET /catalog` beserta metadata pagination-nya.
class CatalogPage {
  final List<CatalogCourseModel> courses;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;
  final bool showPrice;

  const CatalogPage({
    required this.courses,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.hasMorePages,
    required this.showPrice,
  });

  factory CatalogPage.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final courses = rawData is List
        ? rawData
              .whereType<Map>()
              .map(
                (item) => CatalogCourseModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
        : <CatalogCourseModel>[];

    final meta = json['meta'];
    final pagination = meta is Map ? meta['pagination'] : null;
    final pageMap = pagination is Map
        ? Map<String, dynamic>.from(pagination)
        : const <String, dynamic>{};

    final currentPage = _asInt(pageMap['currentPage'], fallback: 1);
    final lastPage = _asInt(pageMap['lastPage'], fallback: 1);
    // Default `hasMorePages` mengikuti aturan dokumen: halaman berikutnya ada
    // bila server menyatakan demikian; bila meta tidak ada, bandingkan page.
    final hasMorePages = pageMap['hasMorePages'] is bool
        ? pageMap['hasMorePages'] as bool
        : currentPage < lastPage;

    return CatalogPage(
      courses: courses,
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: _asInt(pageMap['perPage'], fallback: courses.length),
      total: _asInt(pageMap['total'], fallback: courses.length),
      hasMorePages: hasMorePages,
      showPrice: meta is Map && meta['showPrice'] is bool
          ? meta['showPrice'] as bool
          : false,
    );
  }

  CatalogPageEntity toEntity() {
    return CatalogPageEntity(
      courses: courses.map((course) => course.toEntity()).toList(),
      currentPage: currentPage,
      lastPage: lastPage,
      total: total,
      hasMorePages: hasMorePages,
      showPrice: showPrice,
    );
  }

  static int _asInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}
