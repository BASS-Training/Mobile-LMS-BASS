import '../models/catalog_course_model.dart';

abstract class CatalogLocalDataSource {
  Future<List<CatalogCourseModel>> getCatalog();
  Future<Set<String>> getEnrolledCourseIds();
  Future<void> enroll(String catalogId);
}
