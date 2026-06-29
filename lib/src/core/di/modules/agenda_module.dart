// Agenda module - DI untuk fitur jadwal/kalender.
// Menggabungkan: sesi terjadwal (API), hari libur nasional (Google ICS + cache),
// dan agenda pribadi (Hive lokal).
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/agenda/data/agenda_repository.dart';
import 'package:lms_mobile_app/src/features/agenda/data/holiday_repository.dart';
import 'package:lms_mobile_app/src/features/agenda/data/personal_agenda_remote_data_source.dart';
import 'package:lms_mobile_app/src/features/agenda/data/personal_agenda_store.dart';
import 'package:lms_mobile_app/src/features/agenda/presentation/cubit/agenda_cubit.dart';

/// Modul DI fitur Agenda: repository sesi, repository hari libur, store agenda
/// pribadi, dan AgendaCubit (singleton, dibagi Home & layar Jadwal).
/// Lihat ARCHITECTURE.md §6.
class AgendaModule {
  static void register(GetIt getIt) {
    if (getIt.isRegistered<AgendaRepository>()) {
      return;
    }

    getIt.registerLazySingleton<AgendaRepository>(
      () => AgendaRepository(dio: getIt<Dio>()),
    );
    getIt.registerLazySingleton<HolidayRepository>(() => HolidayRepository());
    getIt.registerLazySingleton<PersonalAgendaRemoteDataSource>(
      () => PersonalAgendaRemoteDataSourceImpl(dio: getIt<Dio>()),
    );
    getIt.registerLazySingleton<PersonalAgendaStore>(
      () => PersonalAgendaStore(
        remote: getIt<PersonalAgendaRemoteDataSource>(),
      ),
    );

    getIt.registerLazySingleton<AgendaCubit>(
      () => AgendaCubit(
        repository: getIt<AgendaRepository>(),
        holidayRepository: getIt<HolidayRepository>(),
        personalStore: getIt<PersonalAgendaStore>(),
      ),
    );
  }
}
