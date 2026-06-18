/// Kunci tanggal seragam `yyyy-mm-dd` (komponen tanggal lokal) untuk memetakan
/// hari libur, sesi, dan agenda pribadi ke hari yang sama di seluruh fitur.
String dateKey(DateTime d) {
  final l = d.toLocal();
  final m = l.month.toString().padLeft(2, '0');
  final day = l.day.toString().padLeft(2, '0');
  return '${l.year}-$m-$day';
}

/// Apakah dua [DateTime] jatuh pada hari yang sama (waktu lokal).
bool isSameDay(DateTime a, DateTime b) => dateKey(a) == dateKey(b);
