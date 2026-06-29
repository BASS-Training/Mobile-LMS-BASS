// Game module - dependency injection untuk games feature
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/games/data/datasources/game_local_data_source.dart';
import 'package:lms_mobile_app/src/features/games/data/datasources/game_remote_data_source.dart';
import 'package:lms_mobile_app/src/features/games/data/repositories/game_score_repository_impl.dart';
import 'package:lms_mobile_app/src/features/games/domain/repositories/game_score_repository.dart';
import 'package:lms_mobile_app/src/features/games/domain/usecases/get_all_game_scores.dart';
import 'package:lms_mobile_app/src/features/games/domain/usecases/get_game_score.dart';
import 'package:lms_mobile_app/src/features/games/domain/usecases/manage_board_state.dart';
import 'package:lms_mobile_app/src/features/games/domain/usecases/submit_game_result.dart';
import 'package:lms_mobile_app/src/features/games/presentation/hub/bloc/games_hub_bloc.dart';

/// Modul DI fitur Game: mendaftarkan datasource skor (Hive), repository, dan
/// GamesHubBloc untuk mini-games. Dipanggil oleh [ServiceLocator]. Lihat ARCHITECTURE.md §6.
class GameModule {
  static void register(GetIt getIt) {
    if (getIt.isRegistered<GameScoreRepository>()) {
      return;
    }

    // Data Source
    final GameLocalDataSource localDataSource = GameLocalDataSourceImpl();
    final GameRemoteDataSource remoteDataSource =
        GameRemoteDataSourceImpl(dio: getIt<Dio>());

    // Repository
    getIt.registerLazySingleton<GameScoreRepository>(
      () => GameScoreRepositoryImpl(
        localDataSource: localDataSource,
        remote: remoteDataSource,
      ),
    );

    // Use Cases — registered so both the hub bloc and the (setState-driven)
    // game screens can resolve them.
    getIt.registerLazySingleton(() => GetGameScore(getIt()));
    getIt.registerLazySingleton(() => GetAllGameScores(getIt()));
    getIt.registerLazySingleton(() => SubmitGameResult(getIt()));
    getIt.registerLazySingleton(() => ManageBoardState(getIt()));

    // Bloc
    getIt.registerFactory<GamesHubBloc>(
      () => GamesHubBloc(getAllGameScores: getIt()),
    );
  }
}
