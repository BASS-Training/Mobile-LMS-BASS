import 'package:hive_flutter/hive_flutter.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/entities/personal_agenda_item.dart';

/// Penyimpanan lokal (Hive) untuk agenda pribadi peserta. Box `bass_calendar_box`
/// dipakai bersama cache hari libur (kunci berbeda). Hive di-init oleh core DI;
/// box dibuka lazy. Mirip pola [GameLocalDataSource].
///
/// Key agenda di-scope per user ([LocalStorage.scopedKey]) supaya agenda akun
/// satu tidak bocor ke akun lain di perangkat yang sama.
class PersonalAgendaStore {
  static const String _boxName = 'bass_calendar_box';
  static const String _eventsKeyBase = 'personal_events';

  String get _eventsKey => LocalStorage.scopedKey(_eventsKeyBase);

  Box? _cachedBox;

  Future<Box> _box() async {
    final cached = _cachedBox;
    if (cached != null && cached.isOpen) return cached;
    final box = Hive.isBoxOpen(_boxName)
        ? Hive.box(_boxName)
        : await Hive.openBox(_boxName);
    _cachedBox = box;
    await _migrateLegacy(box);
    return box;
  }

  /// Pindahkan data agenda global versi lama ke scope user aktif (kasus umum:
  /// satu akun di device), lalu hapus key global agar tidak terbaca akun lain.
  Future<void> _migrateLegacy(Box box) async {
    if (!box.containsKey(_eventsKeyBase)) return;
    if (!box.containsKey(_eventsKey)) {
      await box.put(_eventsKey, box.get(_eventsKeyBase));
    }
    await box.delete(_eventsKeyBase);
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
