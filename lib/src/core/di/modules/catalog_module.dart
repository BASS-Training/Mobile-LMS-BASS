import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../../features/catalog/data/datasources/catalog_local_data_source.dart';
import '../../../features/catalog/data/datasources/catalog_local_data_source_impl.dart';
import '../../../features/catalog/data/datasources/catalog_remote_data_source.dart';
import '../../../features/catalog/data/datasources/catalog_remote_data_source_impl.dart';
import '../../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../../features/catalog/presentation/bloc/catalog_bloc.dart';

class CatalogModule {
  static void register(GetIt getIt) {
    if (getIt.isRegistered<CatalogBloc>()) return;

    getIt.registerLazySingleton<CatalogLocalDataSource>(
      CatalogLocalDataSourceImpl.new,
    );
    getIt.registerLazySingleton<CatalogRemoteDataSource>(
      () => CatalogRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
    getIt.registerLazySingleton<CatalogRepository>(
      () => CatalogRepositoryImpl(
        localDataSource: getIt<CatalogLocalDataSource>(),
        remoteDataSource: getIt<CatalogRemoteDataSource>(),
      ),
    );
    getIt.registerFactory<CatalogBloc>(
      () => CatalogBloc(repository: getIt<CatalogRepository>()),
    );
  }
}
