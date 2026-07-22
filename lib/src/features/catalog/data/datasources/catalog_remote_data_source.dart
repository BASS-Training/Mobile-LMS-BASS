import '../models/catalog_course_model.dart';

/// Payload mentah endpoint daftar katalog: item + flag kebijakan dari server.
class CatalogPayload {
  final List<CatalogCourseModel> courses;
  final bool showPrice;

  const CatalogPayload({required this.courses, required this.showPrice});
}

/// Kontrak sumber data jaringan untuk etalase kursus.
abstract class CatalogRemoteDataSource {
  Future<CatalogPayload> fetchCatalog({String? query, String? priceFilter});

  Future<CatalogCourseModel> fetchCatalogCourse(String id);

  Future<void> enrollFree(String id);
}
