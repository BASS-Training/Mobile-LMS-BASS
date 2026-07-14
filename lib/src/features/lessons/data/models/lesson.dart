class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String content;
  final String duration;
  final String
  type; // 'video', 'text', 'document', 'quiz', 'essay', 'image', 'zoom'
  final String? youtubeVideoId;
  final String? documentUrl;
  final List<String> imageUrls;
  // Zoom-specific fields
  final String? zoomLink;
  final String? zoomMeetingId;
  final String? zoomPassword;
  final String? scheduledStart; // ISO 8601
  final String? scheduledEnd; // ISO 8601
  // Kehadiran (attendance): bila diaktifkan admin, konten berikutnya terkunci
  // sampai instruktur menandai kehadiran peserta di web.
  final bool attendanceRequired;
  final int? minAttendanceMinutes;
  final String? attendanceNotes;
  // Status kehadiran user: 'present'|'absent'|'late'|'excused', atau null bila
  // belum ditandai instruktur (menunggu ACC).
  final String? attendanceStatus;
  // Pengumpulan tugas dokumen (lihat LessonEntity).
  final bool collectSubmission;
  final bool requireSubmissionPass;
  final String? submissionStatus;
  bool isCompleted;

  Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    required this.duration,
    this.type = 'text',
    this.youtubeVideoId,
    this.documentUrl,
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
    this.collectSubmission = false,
    this.requireSubmissionPass = false,
    this.submissionStatus,
    this.isCompleted = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    final content = (json['content'] ?? json['body'] ?? '') as String;
    final videoSource =
        json['youtubeVideoId'] ??
        json['youtubeVideoUrl'] ??
        (json['type'] == 'video' ? content : null);
    final documentUrl =
        json['documentUrl'] ?? json['filePath'] ?? json['file_path'];

    return Lesson(
      id: json['id'] ?? '',
      courseId: json['courseId'] ?? '',
      title: json['title'] ?? '',
      content: content,
      duration: json['duration'] ?? '0 min',
      type: json['type'] ?? 'text',
      youtubeVideoId: videoSource,
      documentUrl: documentUrl,
      isCompleted: json['isCompleted'] ?? false,
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.whereType<String>()
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      zoomLink: json['zoomLink'] as String?,
      zoomMeetingId: json['zoomMeetingId'] as String?,
      zoomPassword: json['zoomPassword'] as String?,
      scheduledStart: json['scheduledStart'] as String?,
      scheduledEnd: json['scheduledEnd'] as String?,
      attendanceRequired: json['attendanceRequired'] == true,
      minAttendanceMinutes: (json['minAttendanceMinutes'] as num?)?.toInt(),
      attendanceNotes: json['attendanceNotes'] as String?,
      attendanceStatus: json['attendanceStatus'] as String?,
      collectSubmission: json['collectSubmission'] == true,
      requireSubmissionPass: json['requireSubmissionPass'] == true,
      submissionStatus: json['submissionStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'title': title,
      'content': content,
      'duration': duration,
      'type': type,
      'youtubeVideoId': youtubeVideoId,
      'documentUrl': documentUrl,
      'imageUrls': imageUrls,
      'zoomLink': zoomLink,
      'zoomMeetingId': zoomMeetingId,
      'zoomPassword': zoomPassword,
      'scheduledStart': scheduledStart,
      'scheduledEnd': scheduledEnd,
      'attendanceRequired': attendanceRequired,
      'minAttendanceMinutes': minAttendanceMinutes,
      'attendanceNotes': attendanceNotes,
      'attendanceStatus': attendanceStatus,
      'collectSubmission': collectSubmission,
      'requireSubmissionPass': requireSubmissionPass,
      'submissionStatus': submissionStatus,
      'isCompleted': isCompleted,
    };
  }

  Lesson copyWith({
    bool? isCompleted,
    String? type,
    String? youtubeVideoId,
    String? documentUrl,
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
    bool? collectSubmission,
    bool? requireSubmissionPass,
    String? submissionStatus,
  }) {
    return Lesson(
      id: id,
      courseId: courseId,
      title: title,
      content: content,
      duration: duration,
      type: type ?? this.type,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      documentUrl: documentUrl ?? this.documentUrl,
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
      collectSubmission: collectSubmission ?? this.collectSubmission,
      requireSubmissionPass:
          requireSubmissionPass ?? this.requireSubmissionPass,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
