import 'package:equatable/equatable.dart';

/// Satu percobaan (attempt) pengumpulan dokumen milik peserta.
class DocumentSubmissionAttempt extends Equatable {
  final String submissionId;
  final int attempt;
  final String status; // draft | submitted | passed | failed
  final String? originalName;
  final String? fileUrl;
  final int? fileSize;
  final int? score;
  final String? feedback;
  final DateTime? submittedAt;
  final DateTime? gradedAt;

  const DocumentSubmissionAttempt({
    required this.submissionId,
    required this.attempt,
    required this.status,
    this.originalName,
    this.fileUrl,
    this.fileSize,
    this.score,
    this.feedback,
    this.submittedAt,
    this.gradedAt,
  });

  bool get isDraft => status == 'draft';
  bool get isSubmitted => status == 'submitted';
  bool get isPassed => status == 'passed';
  bool get isFailed => status == 'failed';
  bool get hasFile => (fileUrl ?? '').isNotEmpty;

  String get statusLabel => switch (status) {
    'draft' => 'Belum dikumpulkan',
    'submitted' => 'Menunggu penilaian',
    'passed' => 'Lulus',
    'failed' => 'Belum lulus',
    _ => status,
  };

  @override
  List<Object?> get props => [
    submissionId,
    attempt,
    status,
    originalName,
    fileUrl,
    fileSize,
    score,
    feedback,
    submittedAt,
    gradedAt,
  ];
}

/// Konfigurasi + seluruh attempt milik peserta untuk sebuah konten dokumen.
class DocumentSubmissionData extends Equatable {
  final String lessonId;
  final String title;
  final String? instructions;
  final int maxSizeMb;
  final String allowedTypes; // csv, mis. "pdf,doc,docx"
  final bool scoringEnabled;
  final bool requireSubmissionPass;
  final String activeStatus; // none | draft | submitted | passed | failed
  final bool canUpload;
  final int nextAttempt;
  final List<DocumentSubmissionAttempt> submissions; // urut attempt asc

  const DocumentSubmissionData({
    required this.lessonId,
    required this.title,
    this.instructions,
    this.maxSizeMb = 20,
    this.allowedTypes = 'pdf,doc,docx,ppt,pptx,xls,xlsx,txt,jpg,jpeg,png,zip,rar',
    this.scoringEnabled = true,
    this.requireSubmissionPass = false,
    this.activeStatus = 'none',
    this.canUpload = true,
    this.nextAttempt = 1,
    this.submissions = const [],
  });

  DocumentSubmissionAttempt? get latest =>
      submissions.isNotEmpty ? submissions.last : null;

  bool get isDraft => activeStatus == 'draft';
  bool get isWaiting => activeStatus == 'submitted';
  bool get isPassed => activeStatus == 'passed';
  bool get isFailed => activeStatus == 'failed';

  /// Ekstensi diizinkan sebagai list bersih (lowercase, tanpa titik).
  List<String> get allowedExtensions => allowedTypes
      .split(',')
      .map((e) => e.trim().toLowerCase())
      .where((e) => e.isNotEmpty)
      .toList();

  /// Riwayat attempt yang sudah dikumpulkan (bukan draft), terbaru dahulu.
  List<DocumentSubmissionAttempt> get history =>
      submissions.where((s) => s.status != 'draft').toList().reversed.toList();

  @override
  List<Object?> get props => [
    lessonId,
    title,
    instructions,
    maxSizeMb,
    allowedTypes,
    scoringEnabled,
    requireSubmissionPass,
    activeStatus,
    canUpload,
    nextAttempt,
    submissions,
  ];
}

/// Pengumpulan seorang peserta (untuk tampilan instruktur/admin).
class DocumentSubmissionParticipant extends Equatable {
  final String userId;
  final String name;
  final String email;
  final int attemptCount;
  final String latestStatus; // draft | submitted | passed | failed
  final List<DocumentSubmissionAttempt> submissions; // terbaru dahulu

  const DocumentSubmissionParticipant({
    required this.userId,
    required this.name,
    required this.email,
    required this.attemptCount,
    required this.latestStatus,
    this.submissions = const [],
  });

  /// Attempt terbaru yang sudah dikumpulkan (bisa dinilai).
  DocumentSubmissionAttempt? get gradable {
    for (final s in submissions) {
      if (s.status != 'draft') return s;
    }
    return null;
  }

  @override
  List<Object?> get props =>
      [userId, name, email, attemptCount, latestStatus, submissions];
}

/// Daftar pengumpulan seluruh peserta untuk sebuah konten (instruktur/admin).
class DocumentSubmissionManage extends Equatable {
  final String contentId;
  final String title;
  final bool scoringEnabled;
  final List<DocumentSubmissionParticipant> participants;

  const DocumentSubmissionManage({
    required this.contentId,
    required this.title,
    this.scoringEnabled = true,
    this.participants = const [],
  });

  @override
  List<Object?> get props => [contentId, title, scoringEnabled, participants];
}
