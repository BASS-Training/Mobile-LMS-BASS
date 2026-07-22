import '../repositories/catalog_repository.dart';

/// Mendaftarkan user ke kursus etalase yang GRATIS.
///
/// Ini satu-satunya aksi "mendapatkan kursus" yang tersedia di mobile. Kursus
/// berbayar tidak punya padanannya di sini — dan itu disengaja.
class EnrollFreeCourseUseCase {
  final CatalogRepository repository;

  EnrollFreeCourseUseCase(this.repository);

  Future<void> call(String id) {
    return repository.enrollFree(id);
  }
}
