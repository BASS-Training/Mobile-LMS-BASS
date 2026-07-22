import '../entities/catalog_course_entity.dart';
import '../repositories/catalog_repository.dart';

/// Memuat preview satu kursus etalase beserta outline kurikulumnya.
class GetCatalogCourseUseCase {
  final CatalogRepository repository;

  GetCatalogCourseUseCase(this.repository);

  Future<CatalogCourseEntity> call(String id) {
    return repository.getCatalogCourse(id);
  }
}
