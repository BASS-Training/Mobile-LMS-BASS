import 'package:hive_flutter/hive_flutter.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/agenda/data/personal_agenda_remote_data_source.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/entities/personal_agenda_item.dart';

/// Penyimpanan agenda pribadi peserta.
///
/// Server (`/mobile/agenda/personal`) adalah sumber kebenaran agar agenda
/// tersinkron lintas device & web; box Hive `bass_calendar_box` dipakai sebagai
/// cache offline. Key Hive di-scope per user ([LocalStorage.scopedKey]) supaya
/// tidak bocor antar-akun di perangkat yang sama.
///
/// Saat [remote] null (mis. mode tes/offline), store jatuh ke perilaku
/// lokal-saja seperti sebelumnya.
class PersonalAgendaStore {
  static const String _boxName = 'bass_calendar_box';
  static const String _eventsKeyBase = 'personal_events';

  final PersonalAgendaRemoteDataSource? remote;

  PersonalAgendaStore({this.remote});

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

  Future<List<PersonalAgendaItem>> _readLocal() async {
    final box = await _box();
    final raw = box.get(_eventsKey);
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => PersonalAgendaItem.fromMap(e))
        .toList();
  }

  Future<void> _writeLocal(List<PersonalAgendaItem> items) async {
    final box = await _box();
    await box.put(_eventsKey, items.map((e) => e.toMap()).toList());
  }

  /// Daftar agenda. Online: tarik dari server, push item lokal yang belum
  /// tersinkron (migrasi data lama / dibuat saat offline), lalu cerminkan ke
  /// cache. Offline: kembalikan cache lokal.
  Future<List<PersonalAgendaItem>> getAll() async {
    final local = await _readLocal();
    final r = remote;
    if (r == null) return local;

    try {
      final server = await r.fetchAll();
      final serverIds = server.map((e) => e.id).toSet();

      // Item yang belum ada di server: legacy lokal-saja atau dibuat offline.
      final pending = local.where((e) => !serverIds.contains(e.id)).toList();
      final failed = <PersonalAgendaItem>[];
      for (final item in pending) {
        try {
          await r.create(item);
        } catch (_) {
          failed.add(item);
        }
      }

      // Jika ada yang berhasil di-push, ambil ulang daftar otoritatif.
      final fresh = pending.length > failed.length ? await r.fetchAll() : server;

      // Item yang gagal di-push tetap dipertahankan agar tidak hilang.
      final merged = [...fresh, ...failed];
      await _writeLocal(merged);
      return merged;
    } catch (_) {
      // Offline / server tak terjangkau → pakai cache.
      return local;
    }
  }

  Future<void> add(PersonalAgendaItem item) async {
    final r = remote;
    if (r != null) {
      try {
        final created = await r.create(item);
        final local = await _readLocal()..add(created);
        await _writeLocal(local);
        return;
      } catch (_) {
        // Offline → simpan lokal; akan di-push saat getAll() berikutnya online.
      }
    }
    final local = await _readLocal()..add(item);
    await _writeLocal(local);
  }

  Future<void> remove(String id) async {
    final r = remote;
    if (r != null) {
      try {
        await r.delete(id);
      } catch (_) {
        // Offline → tetap hapus dari cache lokal.
      }
    }
    final local = await _readLocal()..removeWhere((e) => e.id == id);
    await _writeLocal(local);
  }
}
