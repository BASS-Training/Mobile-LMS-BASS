import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/entities/agenda_item.dart';
import 'package:lms_mobile_app/src/features/agenda/domain/entities/personal_agenda_item.dart';

/// Menjadwalkan **notifikasi lokal** sebagai pengingat jadwal — sepenuhnya di
/// sisi perangkat, tanpa endpoint backend baru. Sumber datanya:
///  • sesi terjadwal ([AgendaItem], mis. Zoom) → diingatkan beberapa menit
///    sebelum `scheduledStart`;
///  • agenda pribadi ([PersonalAgendaItem]) → diingatkan sebelum waktunya (atau
///    pagi hari itu bila acara tanpa jam).
///
/// Catatan: tugas (essay/studi kasus/dokumen) TIDAK diingatkan karena data
/// backend tidak menyimpan tenggat — kita tidak mengarang tanggal jatuh tempo.
///
/// Singleton (pola sama seperti ThemeController). [init] dipanggil sekali di
/// CoreModule; [sync] dipanggil tiap data agenda dimuat/berubah; [cancelAll]
/// saat logout agar pengingat akun sebelumnya tidak terbawa.
class ReminderService {
  ReminderService._();
  static final ReminderService instance = ReminderService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _channelId = 'agenda_reminders';
  static const String _channelName = 'Pengingat Jadwal';
  static const String _channelDesc =
      'Pengingat sesi terjadwal & agenda pribadi';

  /// Basis namespace id notifikasi agar tak bentrok dengan fitur lain.
  static const int _idBase = 100000;

  /// Siapkan plugin, zona waktu, dan channel Android. Aman dipanggil berkali-kali.
  Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      _configureLocalTimeZone();

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      // Jangan minta izin saat init (sebelum login) — ditunda ke [sync]/toggle.
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        settings:
            const InitializationSettings(android: androidInit, iOS: darwinInit),
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
        ),
      );
      _initialized = true;
    } catch (_) {
      // Diam — app harus tetap jalan meski penjadwalan tak tersedia.
    }
  }

  /// Indonesia tak ber-DST; petakan offset perangkat ke zona IANA yang sesuai
  /// agar `zonedSchedule` menembak di waktu lokal yang benar (WIB/WITA/WIT).
  void _configureLocalTimeZone() {
    final hours = DateTime.now().timeZoneOffset.inHours;
    final name = switch (hours) {
      9 => 'Asia/Jayapura', // WIT
      8 => 'Asia/Makassar', // WITA
      _ => 'Asia/Jakarta', // WIB (default & fallback)
    };
    try {
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    }
  }

  /// Minta izin notifikasi (Android 13+ & iOS). OS hanya menampilkan dialog
  /// sekali; panggilan berikutnya mengembalikan status tersimpan tanpa prompt.
  Future<bool> requestPermissionIfNeeded() async {
    await init();
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final androidGranted = await android?.requestNotificationsPermission();

      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final iosGranted = await ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      // Bila platform tak mengembalikan status (null), anggap boleh mencoba.
      return (androidGranted ?? true) || (iosGranted ?? true);
    } catch (_) {
      return false;
    }
  }

  /// Jadwalkan ULANG seluruh pengingat dari data terkini. Membatalkan pengingat
  /// yang kita jadwalkan sebelumnya lalu memasang yang baru untuk acara mendatang.
  Future<void> sync({
    required List<AgendaItem> sessions,
    required List<PersonalAgendaItem> personal,
  }) async {
    await init();
    try {
      await _cancelTracked();
      if (!LocalStorage.getRemindersEnabled()) return;

      // Pastikan izin (diam bila sudah pernah diputuskan pengguna).
      await requestPermissionIfNeeded();

      final lead = Duration(minutes: LocalStorage.getReminderLeadMinutes());
      final now = DateTime.now();
      final ids = <int>[];

      for (final s in sessions) {
        final start = s.scheduledStart?.toLocal();
        if (start == null || !start.isAfter(now)) continue; // lewat/tak berjam
        final id = _idFor('session', s.contentId);
        final fireAt = start.subtract(lead);
        final body = _sessionBody(s, start);
        if (fireAt.isAfter(now)) {
          await _zoned(
            id: id,
            title: '${_leadLabel(lead)} • ${s.title}',
            body: body,
            when: fireAt,
          );
        } else {
          // Acara lebih dekat dari lead-time tapi belum mulai → ingatkan sekarang.
          await _showNow(id: id, title: 'Sebentar lagi • ${s.title}', body: body);
        }
        ids.add(id);
      }

      for (final p in personal) {
        final id = _idFor('personal', p.id);
        final body = (p.note != null && p.note!.trim().isNotEmpty)
            ? p.note!.trim()
            : 'Agenda pribadimu${p.hasTime ? ' pukul ${p.timeLabel}' : ''}';
        final d = p.date;
        if (p.hasTime) {
          final event = DateTime(d.year, d.month, d.day, p.hour!, p.minute!);
          if (!event.isAfter(now)) continue; // sudah lewat
          final fireAt = event.subtract(lead);
          if (fireAt.isAfter(now)) {
            await _zoned(id: id, title: p.title, body: body, when: fireAt);
          } else {
            await _showNow(id: id, title: 'Sebentar lagi • ${p.title}', body: body);
          }
          ids.add(id);
        } else {
          // Acara sepanjang hari: ingatkan pukul 07:00; bila sudah lewat tapi
          // harinya belum usai → ingatkan sekarang.
          final endOfDay = DateTime(d.year, d.month, d.day, 23, 59, 59);
          if (!endOfDay.isAfter(now)) continue; // harinya sudah lewat
          final morning = DateTime(d.year, d.month, d.day, 7, 0);
          if (morning.isAfter(now)) {
            await _zoned(id: id, title: p.title, body: body, when: morning);
          } else {
            await _showNow(id: id, title: p.title, body: body);
          }
          ids.add(id);
        }
      }

      await LocalStorage.setScheduledReminderIds(ids);
    } catch (_) {
      // Diam — kegagalan penjadwalan tak boleh menjatuhkan UI.
    }
  }

  /// Tampilkan notifikasi konfirmasi **seketika** (bukan terjadwal). Dipakai saat
  /// pengguna baru mengaktifkan pengingat: memberi bukti langsung bahwa izin +
  /// channel + tampilan berfungsi, tanpa harus menunggu waktu acara. Memakai id
  /// di luar rentang [_idFor] agar tak menimpa / tertimpa pengingat terjadwal.
  Future<void> showConfirmationNow() async {
    await init();
    try {
      await _plugin.show(
        id: _idBase - 1,
        title: 'Pengingat jadwal aktif ✅',
        body:
            'Kamu akan diingatkan sebelum sesi & agendamu. Notifikasi seperti '
            'inilah yang akan muncul.',
        notificationDetails: _details(),
      );
    } catch (_) {
      // Diam — kegagalan tampil tak boleh menjatuhkan UI.
    }
  }

  /// Batalkan semua pengingat (dipanggil saat logout / mematikan fitur).
  Future<void> cancelAll() async {
    await init();
    try {
      await _cancelTracked();
      // Sapu bersih untuk berjaga-jaga bila ada id lama tak terlacak.
      await _plugin.cancelAll();
      await LocalStorage.setScheduledReminderIds(const []);
    } catch (_) {}
  }

  // ===== helpers =====

  Future<void> _cancelTracked() async {
    for (final id in LocalStorage.getScheduledReminderIds()) {
      await _plugin.cancel(id: id);
    }
    await LocalStorage.setScheduledReminderIds(const []);
  }

  /// Detail notifikasi bersama untuk pengingat terjadwal maupun instan.
  NotificationDetails _details() => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      );

  /// Tampilkan notifikasi **seketika** (untuk acara yang lebih dekat dari
  /// lead-time). Lebih andal daripada menjadwalkan alarm beberapa detik ke depan.
  Future<void> _showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details(),
    );
  }

  Future<void> _zoned({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    final scheduled = tz.TZDateTime.from(when, tz.local);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: _details(),
      // Inexact: cukup untuk pengingat & tak butuh izin exact-alarm (ramah Play).
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  String _sessionBody(AgendaItem s, DateTime start) {
    final time =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
    final course = (s.courseTitle != null && s.courseTitle!.isNotEmpty)
        ? ' • ${s.courseTitle}'
        : '';
    return 'Mulai pukul $time$course';
  }

  String _leadLabel(Duration lead) {
    final m = lead.inMinutes;
    if (m <= 0) return 'Segera';
    if (m % 60 == 0) return '${m ~/ 60} jam lagi';
    if (m > 60) return '${m ~/ 60} jam ${m % 60} menit lagi';
    return '$m menit lagi';
  }

  /// Id stabil & positif dari kunci acara, di-namespace dengan [_idBase] agar
  /// sync berulang tidak menggandakan notifikasi (id yang sama = ditimpa).
  int _idFor(String prefix, String key) {
    final h = '$prefix::$key'.hashCode & 0x7fffffff;
    return _idBase + (h % 1000000);
  }
}
