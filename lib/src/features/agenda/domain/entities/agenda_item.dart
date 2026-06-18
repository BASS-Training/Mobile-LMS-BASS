import 'package:equatable/equatable.dart';

/// Satu sesi terjadwal (mis. Zoom) pada agenda peserta.
///
/// Diturunkan dari `contents.scheduled_start/scheduled_end` di backend, jadi
/// selalu sinkron dengan web. `status` dihitung server-side (upcoming/ongoing).
class AgendaItem extends Equatable {
  final String contentId;
  final String title;
  final String type;
  final String? courseId;
  final String? courseTitle;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final String status; // 'upcoming' | 'ongoing'

  const AgendaItem({
    required this.contentId,
    required this.title,
    required this.type,
    this.courseId,
    this.courseTitle,
    this.scheduledStart,
    this.scheduledEnd,
    this.status = 'upcoming',
  });

  bool get isOngoing => status == 'ongoing';

  /// Apakah sesi jatuh pada hari ini (waktu lokal).
  bool get isToday {
    final s = scheduledStart;
    if (s == null) return false;
    final now = DateTime.now();
    final l = s.toLocal();
    return l.year == now.year && l.month == now.month && l.day == now.day;
  }

  factory AgendaItem.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic v) =>
        v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

    return AgendaItem(
      contentId: '${json['contentId'] ?? ''}',
      title: '${json['title'] ?? 'Sesi'}',
      type: '${json['type'] ?? 'zoom'}',
      courseId: json['courseId']?.toString(),
      courseTitle: json['courseTitle']?.toString(),
      scheduledStart: parse(json['scheduledStart']),
      scheduledEnd: parse(json['scheduledEnd']),
      status: '${json['status'] ?? 'upcoming'}',
    );
  }

  @override
  List<Object?> get props => [
    contentId,
    title,
    type,
    courseId,
    courseTitle,
    scheduledStart,
    scheduledEnd,
    status,
  ];
}
