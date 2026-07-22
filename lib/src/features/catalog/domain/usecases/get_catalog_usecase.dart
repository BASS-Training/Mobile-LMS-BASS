import '../entities/catalog_result.dart';
import '../repositories/catalog_repository.dart';

/// Memuat daftar kursus etalase (opsional dengan pencarian & filter harga).
class GetCatalogUseCase {
  final CatalogRepository repository;

  GetCatalogUseCase(this.repository);

  Future<CatalogResult> call({
    String? query,
    CatalogPriceFilter filter = CatalogPriceFilter.all,
  }) {
    return repository.getCatalog(query: query, filter: filter);
  }
}
