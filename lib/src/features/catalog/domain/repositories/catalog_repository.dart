import '../entities/catalog_course_entity.dart';
import '../entities/catalog_result.dart';

/// Kontrak (Domain) untuk etalase kursus.
///
/// Perhatikan yang TIDAK ada di sini: tidak ada `purchase`, `checkout`, atau
/// apa pun yang menggiring ke pembayaran. Satu-satunya aksi yang mengubah data
/// adalah [enrollFree] — dan itu hanya untuk kursus gratis, sehingga tidak
/// bersinggungan dengan Google Play Billing.
abstract class CatalogRepository {
  /// Daftar kursus etalase, opsional disaring kata kunci & harga.
  Future<CatalogResult> getCatalog({String? query, CatalogPriceFilter filter});

  /// Preview satu kursus lengkap dengan outline kurikulum (judul saja).
  Future<CatalogCourseEntity> getCatalogCourse(String id);

  /// Daftar ke kursus GRATIS. Melempar bila kursus berbayar.
  Future<void> enrollFree(String id);
}
