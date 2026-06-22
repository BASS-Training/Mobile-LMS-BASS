// Notification module - DI untuk fitur notifikasi (feed gabungan: notifikasi
// DB + pengumuman web). NotificationsCubit dibuat singleton agar badge bel &
// layar daftar berbagi satu sumber kebenaran.
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/notifications/data/notification_repository.dart';
import 'package:lms_mobile_app/src/features/notifications/presentation/cubit/notifications_cubit.dart';

/// Modul DI fitur Notifikasi: mendaftarkan repository dan NotificationsCubit
/// (singleton global, dibagi Home & layar notifikasi). Lihat ARCHITECTURE.md §6.
class NotificationModule {
  static void register(GetIt getIt) {
    if (getIt.isRegistered<NotificationRepository>()) {
      return;
    }

    getIt.registerLazySingleton<NotificationRepository>(
      () => NotificationRepository(dio: getIt<Dio>()),
    );

    getIt.registerLazySingleton<NotificationsCubit>(
      () => NotificationsCubit(repository: getIt<NotificationRepository>()),
    );
  }
}
