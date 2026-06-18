// Agenda module - DI untuk fitur jadwal (sesi terjadwal/Zoom lintas course).
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/agenda/data/agenda_repository.dart';
import 'package:lms_mobile_app/src/features/agenda/presentation/cubit/agenda_cubit.dart';

/// Modul DI fitur Agenda: mendaftarkan repository dan AgendaCubit (singleton,
/// dibagi Home & layar Jadwal). Lihat ARCHITECTURE.md §6.
class AgendaModule {
  static void register(GetIt getIt) {
    if (getIt.isRegistered<AgendaRepository>()) {
      return;
    }

    getIt.registerLazySingleton<AgendaRepository>(
      () => AgendaRepository(dio: getIt<Dio>()),
    );

    getIt.registerLazySingleton<AgendaCubit>(
      () => AgendaCubit(repository: getIt<AgendaRepository>()),
    );
  }
}
