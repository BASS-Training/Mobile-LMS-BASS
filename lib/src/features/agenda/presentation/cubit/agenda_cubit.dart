import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/agenda/data/agenda_repository.dart';
import 'package:lms_mobile_app/src/features/agenda/data/holiday_repository.dart';
import 'package:lms_mobile_app/src/features/agenda/data/personal_agenda_store.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/agenda_date.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/entities/agenda_item.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/entities/personal_agenda_item.dart';

enum AgendaStatus { initial, loading, loaded, error }

class AgendaState extends Equatable {
  /// Status pemuatan sesi terjadwal (dari API).
  final AgendaStatus status;
  final List<AgendaItem> sessions;
  final List<PersonalAgendaItem> personal;

  /// Peta `yyyy-mm-dd → nama libur` untuk tahun-tahun yang sudah dimuat.
  final Map<String, String> holidays;

  /// Bulan yang sedang ditampilkan (selalu tanggal 1).
  final DateTime focusedMonth;
  final DateTime selectedDay;
  final String? error;

  const AgendaState({
    this.status = AgendaStatus.initial,
    this.sessions = const [],
    this.personal = const [],
    this.holidays = const {},
    required this.focusedMonth,
    required this.selectedDay,
    this.error,
  });

  AgendaState copyWith({
    AgendaStatus? status,
    List<AgendaItem>? sessions,
    List<PersonalAgendaItem>? personal,
    Map<String, String>? holidays,
    DateTime? focusedMonth,
    DateTime? selectedDay,
    String? error,
  }) => AgendaState(
    status: status ?? this.status,
    sessions: sessions ?? this.sessions,
    personal: personal ?? this.personal,
    holidays: holidays ?? this.holidays,
    focusedMonth: focusedMonth ?? this.focusedMonth,
    selectedDay: selectedDay ?? this.selectedDay,
    error: error,
  );

  String? holidayFor(DateTime day) => holidays[dateKey(day)];

  List<AgendaItem> sessionsOn(DateTime day) => sessions
      .where((s) => s.scheduledStart != null && isSameDay(s.scheduledStart!, day))
      .toList();

  List<PersonalAgendaItem> personalOn(DateTime day) =>
      personal.where((p) => isSameDay(p.date, day)).toList();

  /// Apakah hari ini punya penanda apa pun (sesi/agenda pribadi) — untuk titik
  /// penanda di sel kalender.
  bool hasSession(DateTime day) => sessionsOn(day).isNotEmpty;
  bool hasPersonal(DateTime day) => personalOn(day).isNotEmpty;

  @override
  List<Object?> get props => [
    status,
    sessions,
    personal,
    holidays,
    focusedMonth,
    selectedDay,
    error,
  ];
}

class AgendaCubit extends Cubit<AgendaState> {
  final AgendaRepository repository;
  final HolidayRepository holidayRepository;
  final PersonalAgendaStore personalStore;

  final Set<int> _loadedYears = {};

  AgendaCubit({
    required this.repository,
    required this.holidayRepository,
    required this.personalStore,
  }) : super(AgendaState(
          focusedMonth: _firstOfMonth(DateTime.now()),
          selectedDay: DateTime.now(),
        ));

  static DateTime _firstOfMonth(DateTime d) => DateTime(d.year, d.month);

  Future<void> load() async {
    emit(state.copyWith(status: AgendaStatus.loading, error: null));
    try {
      final results = await Future.wait([
        repository.getAgenda(),
        personalStore.getAll(),
      ]);
      final sessions = results[0] as List<AgendaItem>;
      final personal = results[1] as List<PersonalAgendaItem>;
      emit(state.copyWith(
        status: AgendaStatus.loaded,
        sessions: sessions,
        personal: personal,
      ));
      await _ensureHolidays(state.focusedMonth.year);
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      emit(state.copyWith(status: AgendaStatus.error, error: msg));
    }
  }

  /// Pastikan hari libur untuk [year] sudah dimuat & digabung ke state.
  Future<void> _ensureHolidays(int year) async {
    if (_loadedYears.contains(year)) return;
    try {
      final map = await holidayRepository.getHolidays(year);
      _loadedYears.add(year);
      emit(state.copyWith(holidays: {...state.holidays, ...map}));
    } catch (_) {
      // diam — kalender tetap berfungsi tanpa tanggal merah
    }
  }

  void selectDay(DateTime day) => emit(state.copyWith(selectedDay: day));

  void goToMonth(DateTime month) {
    final m = _firstOfMonth(month);
    emit(state.copyWith(focusedMonth: m));
    _ensureHolidays(m.year);
  }

  void nextMonth() =>
      goToMonth(DateTime(state.focusedMonth.year, state.focusedMonth.month + 1));

  void prevMonth() =>
      goToMonth(DateTime(state.focusedMonth.year, state.focusedMonth.month - 1));

  void goToToday() {
    final now = DateTime.now();
    emit(state.copyWith(
      focusedMonth: _firstOfMonth(now),
      selectedDay: now,
    ));
    _ensureHolidays(now.year);
  }

  Future<void> addPersonal(PersonalAgendaItem item) async {
    await personalStore.add(item);
    emit(state.copyWith(personal: await personalStore.getAll()));
  }

  Future<void> removePersonal(String id) async {
    await personalStore.remove(id);
    emit(state.copyWith(personal: await personalStore.getAll()));
  }
}
