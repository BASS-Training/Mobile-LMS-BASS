import 'package:equatable/equatable.dart';

import '../../domain/entities/catalog_course_entity.dart';
import '../../domain/entities/catalog_result.dart';

enum CatalogStatus { initial, loading, success, failure }

/// State etalase. Memakai pola `status` + `copyWith` (lihat ARCHITECTURE.md §10)
/// agar daftar lama tetap tampil selagi pencarian berikutnya dimuat — layar
/// tidak berkedip kosong setiap kali user mengetik.
class CatalogState extends Equatable {
  final CatalogStatus status;
  final List<CatalogCourseEntity> courses;
  final CatalogPriceFilter filter;
  final String query;
  final bool showPrice;
  final String? errorMessage;

  /// Id kursus yang sedang diproses "Daftar Gratis" — untuk spinner per kartu.
  final String? enrollingCourseId;

  const CatalogState({
    this.status = CatalogStatus.initial,
    this.courses = const [],
    this.filter = CatalogPriceFilter.all,
    this.query = '',
    this.showPrice = false,
    this.errorMessage,
    this.enrollingCourseId,
  });

  bool get isEmpty => status == CatalogStatus.success && courses.isEmpty;

  /// Daftar sedang dimuat untuk pertama kali (belum ada apa pun untuk digambar).
  bool get isInitialLoading =>
      status == CatalogStatus.loading && courses.isEmpty;

  CatalogState copyWith({
    CatalogStatus? status,
    List<CatalogCourseEntity>? courses,
    CatalogPriceFilter? filter,
    String? query,
    bool? showPrice,
    String? errorMessage,
    String? enrollingCourseId,
    bool clearError = false,
    bool clearEnrolling = false,
  }) {
    return CatalogState(
      status: status ?? this.status,
      courses: courses ?? this.courses,
      filter: filter ?? this.filter,
      query: query ?? this.query,
      showPrice: showPrice ?? this.showPrice,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      enrollingCourseId: clearEnrolling
          ? null
          : (enrollingCourseId ?? this.enrollingCourseId),
    );
  }

  @override
  List<Object?> get props => [
    status,
    courses,
    filter,
    query,
    showPrice,
    errorMessage,
    enrollingCourseId,
  ];
}
