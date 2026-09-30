import '../models/catalog_course_model.dart';
import '../models/catalog_page_model.dart';

abstract class CatalogRemoteDataSource {
  /// `GET /catalog` — daftar katalog terpaginasi.
  ///
  /// [q] pencarian (2–100 karakter), [harga] `free`/`paid`, [page] minimal 1,
  /// [perPage] 1–50. Nilai kosong/kosong-string tidak dikirim ke server.
  Future<CatalogPage> getCatalog({
    String? q,
    String? harga,
    int page = 1,
    int perPage = 20,
  });

  /// `GET /catalog/{id}` — preview detail (termasuk `description` + `sections`).
  Future<CatalogCourseModel> getDetail(String courseId);

  /// `POST /catalog/{id}/daftar-gratis` — pendaftaran course gratis tanpa body.
  Future<void> enrollFree(String courseId);

  /// `POST /web-session` — URL browser sekali pakai untuk detail course.
  Future<String> createWebSession(String courseId);
}
