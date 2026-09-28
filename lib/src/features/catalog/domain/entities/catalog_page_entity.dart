import 'package:equatable/equatable.dart';

import 'catalog_course_entity.dart';

/// Hasil satu halaman katalog dari server (atau fallback lokal).
class CatalogPageEntity extends Equatable {
  final List<CatalogCourseEntity> courses;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMorePages;
  final bool showPrice;

  const CatalogPageEntity({
    required this.courses,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMorePages,
    required this.showPrice,
  });

  const CatalogPageEntity.empty()
    : courses = const [],
      currentPage = 1,
      lastPage = 1,
      total = 0,
      hasMorePages = false,
      showPrice = false;

  @override
  List<Object?> get props => [
    courses,
    currentPage,
    lastPage,
    total,
    hasMorePages,
    showPrice,
  ];
}
