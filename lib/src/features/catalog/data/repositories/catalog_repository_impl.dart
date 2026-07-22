import 'package:lms_mobile_app/src/core/utils/local_storage.dart';

import '../../domain/entities/catalog_course_entity.dart';
import '../../domain/entities/catalog_result.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_remote_data_source.dart';
import '../mappers/catalog_mapper.dart';

/// Implementasi kontrak etalase: jaringan → model → entity.
class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogRemoteDataSource remoteDataSource;

  CatalogRepositoryImpl({required this.remoteDataSource});

  @override
  Future<CatalogResult> getCatalog({
    String? query,
    CatalogPriceFilter filter = CatalogPriceFilter.all,
  }) async {
    final payload = await remoteDataSource.fetchCatalog(
      query: query,
      priceFilter: filter.queryValue,
    );

    return CatalogResult(
      courses: payload.courses.map(CatalogMapper.toEntity).toList(),
      showPrice: payload.showPrice,
    );
  }

  @override
  Future<CatalogCourseEntity> getCatalogCourse(String id) async {
    final model = await remoteDataSource.fetchCatalogCourse(id);
    return CatalogMapper.toEntity(model);
  }

  @override
  Future<void> enrollFree(String id) async {
    await remoteDataSource.enrollFree(id);

    // Daftar kursus user baru saja berubah di server. Cache "Kursus Saya"
    // bersifat cache-first, jadi kalau tidak dibuang di sini kursus barunya
    // tidak akan muncul sampai aplikasi dibuka ulang.
    await LocalStorage.clearCoursesCache();
  }
}
