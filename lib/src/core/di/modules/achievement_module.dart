// Achievement module - DI untuk fitur pencapaian.
// Achievement progress dihitung dari HomeStatsEntity; store di sini menyimpan
// tingkat yang sudah dirayakan (Hive + sinkron server) untuk memicu dialog.
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/achievements/data/achievement_remote_data_source.dart';
import 'package:lms_mobile_app/src/features/achievements/data/achievement_store.dart';

/// Modul DI fitur Pencapaian: mendaftarkan [AchievementStore] (Hive + sinkron
/// baseline ke server) untuk melacak tingkat yang sudah dirayakan. Progress
/// sendiri dihitung dari HomeStatsEntity. Lihat ARCHITECTURE.md §6.
class AchievementModule {
  static void register(GetIt getIt) {
    if (getIt.isRegistered<AchievementStore>()) {
      return;
    }
    getIt.registerLazySingleton<AchievementRemoteDataSource>(
      () => AchievementRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
    getIt.registerLazySingleton<AchievementStore>(
      () => AchievementStore(remote: getIt<AchievementRemoteDataSource>()),
    );
  }
}
