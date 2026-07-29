import 'package:equatable/equatable.dart';

/// Sertifikat NYATA yang sudah diterbitkan (record backend, tabel `certificates`
/// yang dibagi dengan web). Kode & tanggal terbit asli; PDF-nya bisa diunduh &
/// diverifikasi publik lewat [downloadUrl] / [verifyUrl].
class CertificateEntity extends Equatable {
  final String id;
  final String certificateCode;
  final String courseId;
  final String courseTitle;
  final DateTime? issuedAt;

  /// URL langsung ke file PDF sertifikat asli (template bergambar) untuk dirender
  /// inline. Kosong bila file belum tersedia di server.
  final String pdfUrl;
  final String downloadUrl;
  final String verifyUrl;

  const CertificateEntity({
    required this.id,
    required this.certificateCode,
    required this.courseId,
    required this.courseTitle,
    required this.issuedAt,
    required this.pdfUrl,
    required this.downloadUrl,
    required this.verifyUrl,
  });

  factory CertificateEntity.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v is String && v.isNotEmpty) return DateTime.tryParse(v)?.toLocal();
      return null;
    }

    return CertificateEntity(
      id: '${json['id'] ?? ''}',
      certificateCode: '${json['certificateCode'] ?? ''}',
      courseId: '${json['courseId'] ?? ''}',
      courseTitle: '${json['courseTitle'] ?? 'Kursus'}',
      issuedAt: parseDate(json['issuedAt']),
      pdfUrl: '${json['pdfUrl'] ?? ''}',
      downloadUrl: '${json['downloadUrl'] ?? ''}',
      verifyUrl: '${json['verifyUrl'] ?? ''}',
    );
  }

  @override
  List<Object?> get props => [id, certificateCode];
}

/// Kursus yang SUDAH memenuhi syarat sertifikat (progress 100%, item bernilai
/// sudah dinilai, kursus punya template) tapi sertifikatnya belum diterbitkan —
/// peserta tinggal menekan "Terbitkan".
class EligibleCourseEntity extends Equatable {
  final String courseId;
  final String courseTitle;

  const EligibleCourseEntity({
    required this.courseId,
    required this.courseTitle,
  });

  factory EligibleCourseEntity.fromJson(Map<String, dynamic> json) {
    return EligibleCourseEntity(
      courseId: '${json['courseId'] ?? ''}',
      courseTitle: '${json['courseTitle'] ?? 'Kursus'}',
    );
  }

  @override
  List<Object?> get props => [courseId];
}

/// Ringkasan sertifikat peserta (mirror dashboard peserta web): daftar yang
/// sudah terbit, daftar yang siap diterbitkan, dan status kelengkapan profil
/// (data profil wajib lengkap sebelum sertifikat boleh dibuat — sama web).
class CertificateOverview extends Equatable {
  final List<CertificateEntity> issued;
  final List<EligibleCourseEntity> eligible;
  final bool profileComplete;
  final List<String> missingProfileFields;

  const CertificateOverview({
    required this.issued,
    required this.eligible,
    required this.profileComplete,
    required this.missingProfileFields,
  });

  const CertificateOverview.empty()
    : issued = const [],
      eligible = const [],
      profileComplete = true,
      missingProfileFields = const [];

  factory CertificateOverview.fromJson(Map<String, dynamic> json) {
    List<T> mapList<T>(dynamic raw, T Function(Map<String, dynamic>) map) {
      if (raw is! List) return const [];
      return raw
          .whereType<Map>()
          .map((e) => map(Map<String, dynamic>.from(e)))
          .toList();
    }

    return CertificateOverview(
      issued: mapList(json['issued'], CertificateEntity.fromJson),
      eligible: mapList(json['eligible'], EligibleCourseEntity.fromJson),
      profileComplete: json['profileComplete'] == true,
      missingProfileFields: (json['missingProfileFields'] is List)
          ? List<String>.from(
              (json['missingProfileFields'] as List).map((e) => '$e'),
            )
          : const [],
    );
  }

  bool get isEmpty => issued.isEmpty && eligible.isEmpty;

  @override
  List<Object?> get props => [
    issued,
    eligible,
    profileComplete,
    missingProfileFields,
  ];
}
