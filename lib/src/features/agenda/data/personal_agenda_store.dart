import 'package:hive_flutter/hive_flutter.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/entities/personal_agenda_item.dart';

/// Penyimpanan lokal (Hive) untuk agenda pribadi peserta. Box `bass_calendar_box`
/// dipakai bersama cache hari libur (kunci berbeda). Hive di-init oleh core DI;
/// box dibuka lazy. Mirip pola [GameLocalDataSource].
class PersonalAgendaStore {
  static const String _boxName = 'bass_calendar_box';
  static const String _eventsKey = 'personal_events';

  Box? _cachedBox;

  Future<Box> _box() async {
    final cached = _cachedBox;
    if (cached != null && cached.isOpen) return cached;
    final box = Hive.isBoxOpen(_boxName)
        ? Hive.box(_boxName)
        : await Hive.openBox(_boxName);
    _cachedBox = box;
    return box;
  }

  Future<List<PersonalAgendaItem>> getAll() async {
    final box = await _box();
    final raw = box.get(_eventsKey);
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => PersonalAgendaItem.fromMap(e))
        .toList();
  }

  Future<void> add(PersonalAgendaItem item) async {
    final box = await _box();
    final current = await getAll();
    current.add(item);
    await box.put(_eventsKey, current.map((e) => e.toMap()).toList());
  }

  Future<void> remove(String id) async {
    final box = await _box();
    final current = await getAll();
    current.removeWhere((e) => e.id == id);
    await box.put(_eventsKey, current.map((e) => e.toMap()).toList());
  }
}
