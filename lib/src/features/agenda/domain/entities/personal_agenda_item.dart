import 'package:equatable/equatable.dart';

/// Agenda pribadi yang dibuat peserta sendiri (disimpan lokal via Hive).
/// Tidak sinkron ke backend — milik perangkat ini saja.
class PersonalAgendaItem extends Equatable {
  final String id;
  final String title;
  final String? note;
  final DateTime date; // tanggal acara (komponen tanggal yang dipakai)
  final int? hour;
  final int? minute;

  const PersonalAgendaItem({
    required this.id,
    required this.title,
    this.note,
    required this.date,
    this.hour,
    this.minute,
  });

  bool get hasTime => hour != null && minute != null;

  String get timeLabel {
    if (!hasTime) return '';
    final h = hour!.toString().padLeft(2, '0');
    final m = minute!.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'note': note,
    'date': date.toIso8601String(),
    'hour': hour,
    'minute': minute,
  };

  factory PersonalAgendaItem.fromMap(Map map) {
    return PersonalAgendaItem(
      id: '${map['id'] ?? ''}',
      title: '${map['title'] ?? ''}',
      note: map['note']?.toString(),
      date: DateTime.tryParse('${map['date']}') ?? DateTime.now(),
      hour: map['hour'] is int ? map['hour'] as int : null,
      minute: map['minute'] is int ? map['minute'] as int : null,
    );
  }

  @override
  List<Object?> get props => [id, title, note, date, hour, minute];
}
