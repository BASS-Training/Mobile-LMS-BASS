import '../entities/catalog_course_entity.dart';
import '../entities/catalog_page_entity.dart';

abstract class CatalogRepository {
  /// Ambil satu halaman katalog.
  ///
  /// [query] dipakai sebagai pencarian (diteruskan ke `q`), [harga] `free`/`paid`,
  /// [page] dimulai dari 1. Nilai default menghasilkan halaman pertama tanpa
  /// filter.
  Future<CatalogPageEntity> getCatalog({
    String? query,
    String? harga,
    int page = 1,
    int perPage = 20,
  });

  /// Ambil preview detail katalog. Mengembalikan `null` bila course tidak
  /// tersedia (404 / bukan bagian katalog).
  Future<CatalogCourseEntity?> getDetail(String catalogId);

  /// Daftar ke course gratis. Melempar error bila gagal.
  Future<void> enroll(String catalogId);

  /// Buat URL handoff sekali pakai untuk membuka detail course di website.
  Future<String> createWebSession(String catalogId);
}
