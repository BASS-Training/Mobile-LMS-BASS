// Achievement module - DI untuk fitur pencapaian.
// Achievement progress dihitung dari HomeStatsEntity (tanpa backend); store di
// sini hanya menyimpan tingkat yang sudah dirayakan (Hive) untuk memicu dialog.
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/achievements/data/achievement_store.dart';

/// Modul DI fitur Pencapaian: mendaftarkan [AchievementStore] (Hive) untuk
/// melacak tingkat yang sudah dirayakan. Progress sendiri dihitung dari
/// HomeStatsEntity tanpa backend. Lihat ARCHITECTURE.md §6.
class AchievementModule {
  static void register(GetIt getIt) {
    if (getIt.isRegistered<AchievementStore>()) {
      return;
    }
    getIt.registerLazySingleton<AchievementStore>(() => AchievementStore());
  }
}
