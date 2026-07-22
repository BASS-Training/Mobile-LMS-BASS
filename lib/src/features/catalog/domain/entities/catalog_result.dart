import 'package:equatable/equatable.dart';

import 'catalog_course_entity.dart';

/// Hasil pemuatan etalase: daftar kursus + kebijakan tampilan dari server.
///
/// [showPrice] dikirim server (bukan konstanta di aplikasi) supaya kebijakan
/// menampilkan harga bisa diubah tanpa merilis ulang ke Google Play. Lihat
/// `config/shop.php` di backend.
class CatalogResult extends Equatable {
  final List<CatalogCourseEntity> courses;
  final bool showPrice;

  const CatalogResult({required this.courses, required this.showPrice});

  @override
  List<Object?> get props => [courses, showPrice];
}

/// Filter harga pada etalase. `all` = tidak memfilter.
enum CatalogPriceFilter {
  all,
  free,
  paid;

  /// Nilai query string yang dipahami backend (`?harga=`). Null untuk `all`.
  String? get queryValue => switch (this) {
    CatalogPriceFilter.all => null,
    CatalogPriceFilter.free => 'free',
    CatalogPriceFilter.paid => 'paid',
  };

  String get label => switch (this) {
    CatalogPriceFilter.all => 'Semua',
    CatalogPriceFilter.free => 'Gratis',
    CatalogPriceFilter.paid => 'Berbayar',
  };
}
