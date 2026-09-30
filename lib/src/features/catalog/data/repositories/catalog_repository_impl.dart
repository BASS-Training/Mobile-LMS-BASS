import '../../../../core/error/app_exception.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/offline_test_mode.dart';
import '../../domain/entities/catalog_course_entity.dart';
import '../../domain/entities/catalog_page_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_local_data_source.dart';
import '../datasources/catalog_remote_data_source.dart';
import '../models/catalog_course_model.dart';
import '../models/catalog_page_model.dart';

/// Sumber kebenaran: API remote (`/catalog`). Asset lokal dipakai sebagai
/// fallback bila remote gagal dan untuk sesi uji offline
/// ([OfflineTestMode.isActive]).
class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogLocalDataSource localDataSource;
  final CatalogRemoteDataSource remoteDataSource;

  const CatalogRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<CatalogPageEntity> getCatalog({
    String? query,
    String? harga,
    int page = 1,
    int perPage = 20,
  }) async {
    if (_isOfflineTestSession()) {
      logDebug('[CATALOG][FETCH] using local dummy getCatalog page=$page');
      return _localCatalog(
        query: query,
        harga: harga,
        page: page,
        perPage: perPage,
      );
    }

    try {
      logDebug('[CATALOG][FETCH] using remote API getCatalog page=$page');
      final catalogPage = await remoteDataSource.getCatalog(
        q: query,
        harga: harga,
        page: page,
        perPage: perPage,
      );
      return catalogPage.toEntity();
    } on UnauthorizedException {
      // Token kedaluwarsa: jangan ditampilkan sebagai katalog dummy.
      rethrow;
    } on ValidationException {
      // Parameter tidak valid: bug konsumsi API, jangan difallback.
      rethrow;
    } catch (error) {
      logDebug('[CATALOG][FETCH] remote gagal, fallback lokal: $error');
      return _localCatalog(
        query: query,
        harga: harga,
        page: page,
        perPage: perPage,
      );
    }
  }

  @override
  Future<CatalogCourseEntity?> getDetail(String catalogId) async {
    if (_isOfflineTestSession()) {
      logDebug('[CATALOG][DETAIL] using local dummy getDetail id=$catalogId');
      return _localDetail(catalogId);
    }

    try {
      logDebug('[CATALOG][DETAIL] using remote API getDetail id=$catalogId');
      final model = await remoteDataSource.getDetail(catalogId);
      return model.toEntity();
    } on UnauthorizedException {
      rethrow;
    } on ServerException catch (error) {
      if (error.statusCode == 404) {
        logDebug('[CATALOG][DETAIL] tidak ditemukan (404) id=$catalogId');
        return null;
      }
      logDebug('[CATALOG][DETAIL] remote gagal, fallback lokal: $error');
      return _localDetail(catalogId);
    } catch (error) {
      logDebug('[CATALOG][DETAIL] remote gagal, fallback lokal: $error');
      return _localDetail(catalogId);
    }
  }

  @override
  Future<void> enroll(String catalogId) async {
    if (_isOfflineTestSession()) {
      logDebug('[CATALOG][ENROLL] using local dummy enroll id=$catalogId');
      await localDataSource.enroll(catalogId);
      return;
    }

    // Pendaftaran ke server dulu (sumber kebenaran). Error diteruskan ke Bloc
    // agar update optimistik di UI bisa dibatalkan.
    logDebug('[CATALOG][ENROLL] using remote API enroll id=$catalogId');
    await remoteDataSource.enrollFree(catalogId);

    // Rekam juga secara lokal supaya fallback (asset dummy) ikut konsisten.
    await localDataSource.enroll(catalogId);
  }

  @override
  Future<String> createWebSession(String catalogId) async {
    if (_isOfflineTestSession()) {
      throw NetworkException(
        message: 'Website tidak tersedia saat mode offline.',
      );
    }

    logDebug('[CATALOG][WEB] creating handoff session id=$catalogId');
    return remoteDataSource.createWebSession(catalogId);
  }

  /// Baca asset dummy, terapkan filter/pencarian/pagination di memori, dan
  /// tandai keanggotaan dari penyimpanan lokal. Dipakai untuk sesi offline dan
  /// saat remote tidak terjangkau.
  Future<CatalogPageEntity> _localCatalog({
    String? query,
    String? harga,
    required int page,
    required int perPage,
  }) async {
    var models = await localDataSource.getCatalog();
    final enrolledIds = await localDataSource.getEnrolledCourseIds();
    models = models
        .map((model) => model.withEnrolled(enrolledIds.contains(model.id)))
        .toList();

    final trimmedQuery = query?.trim() ?? '';
    if (trimmedQuery.length >= 2) {
      final needle = trimmedQuery.toLowerCase();
      models = models
          .where(
            (model) =>
                model.title.toLowerCase().contains(needle) ||
                model.description.toLowerCase().contains(needle),
          )
          .toList();
    }

    if (harga == 'free') {
      models = models.where((model) => model.isFree).toList();
    } else if (harga == 'paid') {
      models = models.where((model) => model.isPaid).toList();
    }

    final total = models.length;
    final lastPage = total == 0 ? 1 : (total / perPage).ceil();
    final safePage = page < 1 ? 1 : page;
    final start = (safePage - 1) * perPage;
    final end = start + perPage > total ? total : start + perPage;
    final slice = start >= total
        ? <CatalogCourseModel>[]
        : models.sublist(start, end);

    return CatalogPage(
      courses: slice,
      currentPage: safePage,
      lastPage: lastPage,
      perPage: perPage,
      total: total,
      hasMorePages: safePage < lastPage,
      showPrice: false,
    ).toEntity();
  }

  Future<CatalogCourseEntity?> _localDetail(String catalogId) async {
    final models = await localDataSource.getCatalog();
    CatalogCourseModel? match;
    for (final model in models) {
      if (model.id == catalogId) {
        match = model;
        break;
      }
    }
    if (match == null) return null;

    final enrolledIds = await localDataSource.getEnrolledCourseIds();
    return match.withEnrolled(enrolledIds.contains(match.id)).toEntity();
  }

  bool _isOfflineTestSession() => OfflineTestMode.isActive();
}
