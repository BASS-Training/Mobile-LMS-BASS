// Home module - dependency injection untuk home feature
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/home/data/datasources/home_remote_data_source.dart';
import 'package:lms_mobile_app/src/features/home/data/datasources/home_remote_data_source_impl.dart';
import 'package:lms_mobile_app/src/features/home/data/repositories/home_repository_impl.dart';
import 'package:lms_mobile_app/src/features/home/domain/usecases/join_class_usecase.dart';
import 'package:lms_mobile_app/src/features/home/presentation/bloc/home_bloc.dart';

class HomeModule {
  static void register(GetIt getIt) {
    if (getIt.isRegistered<HomeBloc>()) {
      return;
    }

    // Data Source
    final HomeRemoteDataSource remoteDataSource = HomeRemoteDataSourceImpl(
      dio: getIt<Dio>(),
    );

    // Repository
    final repository = HomeRepositoryImpl(remoteDataSource: remoteDataSource);

    // Use Case
    final joinClassUseCase = JoinClassUseCase(repository);

    // Bloc
    getIt.registerFactory<HomeBloc>(
      () => HomeBloc(joinClassUseCase: joinClassUseCase),
    );
  }
}
