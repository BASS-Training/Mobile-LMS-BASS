import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Sumber hari libur nasional Indonesia (tanggal merah).
///
/// Mengambil dari kalender libur Indonesia milik Google (format iCal/ICS,
/// keyless & lengkap termasuk libur lunar: Idul Fitri/Adha, Nyepi, Waisak, dst.),
/// lalu mem-parsing-nya menjadi peta `yyyy-mm-dd → nama libur`. Hasilnya
/// di-cache per tahun di Hive (`bass_calendar_box`), dengan fallback ke libur
/// tanggal-tetap saat offline. Memakai Dio bersih (tanpa interceptor auth) agar
/// token kita tidak ikut terkirim ke Google.
class HolidayRepository {
  static const String _icsUrl =
      'https://calendar.google.com/calendar/ical/en.indonesian%23holiday%40group.v.calendar.google.com/public/basic.ics';
  static const String _boxName = 'bass_calendar_box';
  static const Duration _cacheTtl = Duration(days: 30);

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

  /// Peta `yyyy-mm-dd → nama libur` untuk satu [year]. Memakai cache jika masih
  /// segar; jika tidak, mengambil dari jaringan; bila gagal, pakai cache lama
  /// atau fallback libur tanggal-tetap.
  Future<Map<String, String>> getHolidays(int year) async {
    final box = await _box();
    final cacheKey = 'holidays_$year';
    final tsKey = 'holidays_${year}_ts';

    final cachedTs = box.get(tsKey);
    final cachedMap = box.get(cacheKey);
    final fresh = cachedTs is int &&
        DateTime.now().millisecondsSinceEpoch - cachedTs < _cacheTtl.inMilliseconds;

    if (fresh && cachedMap is Map) {
      return cachedMap.map((k, v) => MapEntry('$k', '$v'));
    }

    try {
      final fetched = await _fetchFromIcs(year);
      if (fetched.isNotEmpty) {
        await box.put(cacheKey, fetched);
        await box.put(tsKey, DateTime.now().millisecondsSinceEpoch);
        return fetched;
      }
    } catch (_) {
      // jatuh ke cache/fallback di bawah
    }

    if (cachedMap is Map) {
      return cachedMap.map((k, v) => MapEntry('$k', '$v'));
    }
    return _fallbackFixed(year);
  }

  Future<Map<String, String>> _fetchFromIcs(int year) async {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.plain,
    ));
    final res = await dio.get<String>(_icsUrl);
    final body = res.data ?? '';
    return _parseIcs(body, year);
  }

  /// Parser ICS sederhana: unfold baris terlipat, lalu ambil pasangan
  /// DTSTART (8 digit pertama = yyyymmdd) + SUMMARY untuk tiap VEVENT.
  Map<String, String> _parseIcs(String ics, int year) {
    // Unfold: baris lanjutan diawali spasi/tab digabung ke baris sebelumnya.
    final unfolded = ics.replaceAll(RegExp(r'\r?\n[ \t]'), '');
    final lines = unfolded.split(RegExp(r'\r?\n'));

    final result = <String, String>{};
    String? date;
    String? summary;

    for (final line in lines) {
      if (line == 'BEGIN:VEVENT') {
        date = null;
        summary = null;
      } else if (line.startsWith('DTSTART')) {
        final digits = RegExp(r'(\d{8})').firstMatch(line)?.group(1);
        if (digits != null) {
          date = '${digits.substring(0, 4)}-${digits.substring(4, 6)}-${digits.substring(6, 8)}';
        }
      } else if (line.startsWith('SUMMARY:')) {
        summary = line.substring('SUMMARY:'.length).trim();
      } else if (line == 'END:VEVENT') {
        if (date != null && summary != null && date.startsWith('$year')) {
          // Bersihkan label "Joint Holiday (Cuti Bersama)" tetap ditampilkan apa adanya.
          result.putIfAbsent(date, () => summary!);
        }
      }
    }
    return result;
  }

  /// Libur tanggal-tetap (selalu benar secara Gregorian) untuk mode offline.
  /// Libur lunar sengaja dihilangkan karena tanggalnya berubah tiap tahun.
  Map<String, String> _fallbackFixed(int year) => {
        '$year-01-01': 'Tahun Baru Masehi',
        '$year-05-01': 'Hari Buruh Internasional',
        '$year-06-01': 'Hari Lahir Pancasila',
        '$year-08-17': 'HUT Kemerdekaan RI',
        '$year-12-25': 'Hari Raya Natal',
      };
}
