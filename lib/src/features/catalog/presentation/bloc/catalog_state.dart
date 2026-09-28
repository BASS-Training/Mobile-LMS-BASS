import 'package:equatable/equatable.dart';

import '../../domain/entities/catalog_course_entity.dart';
import '../../domain/entities/catalog_page_entity.dart';

enum CatalogStatus { initial, loading, loaded, failure }

enum CatalogDetailStatus { initial, loading, loaded, failure }

enum CatalogFilter { all, free, paid }

class CatalogState extends Equatable {
  final CatalogStatus status;
  final List<CatalogCourseEntity> courses;
  final CatalogFilter filter;
  final String query;
  final int page;
  final bool hasMorePages;
  final bool isLoadingMore;
  final bool showPrice;
  final String? enrollingId;
  final String? errorMessage;
  final CatalogDetailStatus detailStatus;
  final CatalogCourseEntity? detailCourse;
  final String? detailErrorMessage;

  const CatalogState({
    this.status = CatalogStatus.initial,
    this.courses = const [],
    this.filter = CatalogFilter.all,
    this.query = '',
    this.page = 1,
    this.hasMorePages = false,
    this.isLoadingMore = false,
    this.showPrice = false,
    this.enrollingId,
    this.errorMessage,
    this.detailStatus = CatalogDetailStatus.initial,
    this.detailCourse,
    this.detailErrorMessage,
  });

  /// Data sudah difilter/dipaging oleh repository (remote maupun lokal),
  /// sehingga UI tinggal menampilkan [courses] apa adanya.
  List<CatalogCourseEntity> get visibleCourses => courses;

  CatalogCourseEntity? courseById(String id) {
    for (final course in courses) {
      if (course.id == id) return course;
    }
    return null;
  }

  static const Object _keep = Object();

  CatalogState copyWith({
    CatalogStatus? status,
    List<CatalogCourseEntity>? courses,
    CatalogFilter? filter,
    String? query,
    int? page,
    bool? hasMorePages,
    bool? isLoadingMore,
    bool? showPrice,
    Object? enrollingId = _keep,
    Object? errorMessage = _keep,
    CatalogDetailStatus? detailStatus,
    Object? detailCourse = _keep,
    Object? detailErrorMessage = _keep,
  }) {
    return CatalogState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      page: page ?? this.page,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      showPrice: showPrice ?? this.showPrice,
      enrollingId: identical(enrollingId, _keep)
          ? this.enrollingId
          : enrollingId as String?,
      errorMessage: identical(errorMessage, _keep)
          ? this.errorMessage
          : errorMessage as String?,
      detailStatus: detailStatus ?? this.detailStatus,
      detailCourse: identical(detailCourse, _keep)
          ? this.detailCourse
          : detailCourse as CatalogCourseEntity?,
      detailErrorMessage: identical(detailErrorMessage, _keep)
          ? this.detailErrorMessage
          : detailErrorMessage as String?,
    );
  }

  CatalogState applied(CatalogPageEntity page) {
    return copyWith(
      status: CatalogStatus.loaded,
      courses: page.courses,
      page: page.currentPage,
      hasMorePages: page.hasMorePages,
      showPrice: page.showPrice,
      isLoadingMore: false,
      errorMessage: null,
    );
  }

  CatalogState appended(CatalogPageEntity page) {
    return copyWith(
      status: CatalogStatus.loaded,
      courses: [...courses, ...page.courses],
      page: page.currentPage,
      hasMorePages: page.hasMorePages,
      showPrice: page.showPrice,
      isLoadingMore: false,
      errorMessage: null,
    );
  }

  @override
  List<Object?> get props => [
    status,
    courses,
    filter,
    query,
    page,
    hasMorePages,
    isLoadingMore,
    showPrice,
    enrollingId,
    errorMessage,
    detailStatus,
    detailCourse,
    detailErrorMessage,
  ];
}
