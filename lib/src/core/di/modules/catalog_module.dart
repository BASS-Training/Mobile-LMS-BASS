// Catalog module - DI untuk fitur etalase kursus ("Jelajahi").
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/catalog/data/datasources/catalog_remote_data_source.dart';
import 'package:lms_mobile_app/src/features/catalog/data/datasources/catalog_remote_data_source_impl.dart';
import 'package:lms_mobile_app/src/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/usecases/enroll_free_course_usecase.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/usecases/get_catalog_course_usecase.dart';
import 'package:lms_mobile_app/src/features/catalog/domain/usecases/get_catalog_usecase.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:lms_mobile_app/src/features/catalog/presentation/cubit/catalog_detail_cubit.dart';

/// Modul DI fitur Katalog. Lihat ARCHITECTURE.md §6.
///
/// Cubit-nya `registerFactory` (bukan singleton) karena layar etalase &
/// preview boleh dibuka-tutup berkali-kali dan masing-masing perlu state
/// bersih — berbeda dengan AgendaCubit yang sengaja dibagi lintas layar.
class CatalogModule {
  static void register(GetIt getIt) {
    if (getIt.isRegistered<CatalogRepository>()) {
      return;
    }

    getIt.registerLazySingleton<CatalogRemoteDataSource>(
      () => CatalogRemoteDataSourceImpl(dio: getIt<Dio>()),
    );

    getIt.registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(
        remoteDataSource: getIt<CatalogRemoteDataSource>(),
      ),
    );

    getIt.registerLazySingleton<GetCatalogUseCase>(
      () => GetCatalogUseCase(getIt<CatalogRepository>()),
    );
    getIt.registerLazySingleton<GetCatalogCourseUseCase>(
      () => GetCatalogCourseUseCase(getIt<CatalogRepository>()),
    );
    getIt.registerLazySingleton<EnrollFreeCourseUseCase>(
      () => EnrollFreeCourseUseCase(getIt<CatalogRepository>()),
    );

    getIt.registerFactory<CatalogCubit>(
      () => CatalogCubit(
        getCatalog: getIt<GetCatalogUseCase>(),
        enrollFree: getIt<EnrollFreeCourseUseCase>(),
      ),
    );
    getIt.registerFactory<CatalogDetailCubit>(
      () => CatalogDetailCubit(
        getCourse: getIt<GetCatalogCourseUseCase>(),
        enrollFree: getIt<EnrollFreeCourseUseCase>(),
      ),
    );
  }
}
