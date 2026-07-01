import 'package:equatable/equatable.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/text_section_entity.dart';

/// Objek bisnis murni untuk sebuah lesson/konten (Domain). Catatan penting:
/// `id` di sini setara `content.id` di backend (lihat memory discussion-feature).
/// Pemetaan dari JSON ada di lapisan Data. Lihat ARCHITECTURE.md §3.
class LessonEntity extends Equatable {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final String duration;
  final String type;
  final bool isCompleted;
  final String? youtubeVideoId;
  final String? documentUrl;
  final List<TextSectionEntity>? textSections;
  final List<String> imageUrls;
  // Zoom-specific fields
  final String? zoomLink;
  final String? zoomMeetingId;
  final String? zoomPassword;
  final String? scheduledStart; // ISO 8601
  final String? scheduledEnd; // ISO 8601
  // Kehadiran (attendance): bila diaktifkan admin, lesson berikutnya terkunci
  // sampai instruktur menandai kehadiran peserta di web.
  final bool attendanceRequired;
  final int? minAttendanceMinutes;
  final String? attendanceNotes;
  // 'present'|'absent'|'late'|'excused', atau null bila belum ditandai (pending).
  final String? attendanceStatus;

  const LessonEntity({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.duration,
    this.type = 'text',
    this.isCompleted = false,
    this.youtubeVideoId,
    this.documentUrl,
    this.textSections,
    this.imageUrls = const [],
    this.zoomLink,
    this.zoomMeetingId,
    this.zoomPassword,
    this.scheduledStart,
    this.scheduledEnd,
    this.attendanceRequired = false,
    this.minAttendanceMinutes,
    this.attendanceNotes,
    this.attendanceStatus,
  });

  bool get hasVideo => type == 'video' && (youtubeVideoId?.isNotEmpty ?? false);

  /// Kehadiran diperlukan tetapi belum di-ACC instruktur sebagai hadir/izin.
  /// Selama true, peserta tidak boleh lanjut ke lesson berikutnya.
  bool get attendancePending =>
      attendanceRequired &&
      attendanceStatus != 'present' &&
      attendanceStatus != 'excused';

  LessonEntity copyWith({
    bool? isCompleted,
    String? type,
    String? youtubeVideoId,
    String? documentUrl,
    List<TextSectionEntity>? textSections,
    List<String>? imageUrls,
    String? zoomLink,
    String? zoomMeetingId,
    String? zoomPassword,
    String? scheduledStart,
    String? scheduledEnd,
    bool? attendanceRequired,
    int? minAttendanceMinutes,
    String? attendanceNotes,
    String? attendanceStatus,
  }) {
    return LessonEntity(
      id: id,
      courseId: courseId,
      title: title,
      content: content,
      duration: duration,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      documentUrl: documentUrl ?? this.documentUrl,
      textSections: textSections ?? this.textSections,
      imageUrls: imageUrls ?? this.imageUrls,
      zoomLink: zoomLink ?? this.zoomLink,
      zoomMeetingId: zoomMeetingId ?? this.zoomMeetingId,
      zoomPassword: zoomPassword ?? this.zoomPassword,
      scheduledStart: scheduledStart ?? this.scheduledStart,
      scheduledEnd: scheduledEnd ?? this.scheduledEnd,
      attendanceRequired: attendanceRequired ?? this.attendanceRequired,
      minAttendanceMinutes: minAttendanceMinutes ?? this.minAttendanceMinutes,
      attendanceNotes: attendanceNotes ?? this.attendanceNotes,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
    );
  }

  @override
  List<Object?> get props => [
    id,
    courseId,
    title,
    content,
    duration,
    type,
    isCompleted,
    youtubeVideoId,
    documentUrl,
    textSections,
    imageUrls,
    zoomLink,
    zoomMeetingId,
    zoomPassword,
    scheduledStart,
    scheduledEnd,
    attendanceRequired,
    minAttendanceMinutes,
    attendanceNotes,
    attendanceStatus,
  ];
}
