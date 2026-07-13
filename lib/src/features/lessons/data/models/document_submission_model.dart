import 'package:lms_mobile_app/src/features/lessons/domain/entities/document_submission_entity.dart';

/// Pemetaan JSON API → entity pengumpulan dokumen.
class DocumentSubmissionModel {
  static DateTime? _date(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static DocumentSubmissionAttempt attemptFromApi(Map<String, dynamic> j) {
    return DocumentSubmissionAttempt(
      submissionId: j['submissionId']?.toString() ?? '',
      attempt: _int(j['attempt']) ?? 1,
      status: j['status']?.toString() ?? 'draft',
      originalName: j['originalName'] as String?,
      fileUrl: j['fileUrl'] as String?,
      fileSize: _int(j['fileSize']),
      score: _int(j['score']),
      feedback: j['feedback'] as String?,
      submittedAt: _date(j['submittedAt']),
      gradedAt: _date(j['gradedAt']),
    );
  }

  static DocumentSubmissionData fromApi(Map<String, dynamic> data) {
    final rawSubs = (data['submissions'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => attemptFromApi(Map<String, dynamic>.from(e)))
        .toList();

    return DocumentSubmissionData(
      lessonId: data['lessonId']?.toString() ?? data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      instructions: data['instructions'] as String?,
      maxSizeMb: _int(data['maxSizeMb']) ?? 20,
      allowedTypes: data['allowedTypes']?.toString() ??
          'pdf,doc,docx,ppt,pptx,xls,xlsx,txt,jpg,jpeg,png,zip,rar',
      scoringEnabled: data['scoringEnabled'] != false,
      requireSubmissionPass: data['requireSubmissionPass'] == true,
      activeStatus: data['activeStatus']?.toString() ?? 'none',
      canUpload: data['canUpload'] == true,
      nextAttempt: _int(data['nextAttempt']) ?? 1,
      submissions: rawSubs,
    );
  }

  static DocumentSubmissionParticipant participantFromApi(
    Map<String, dynamic> j,
  ) {
    final subs = (j['submissions'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => attemptFromApi(Map<String, dynamic>.from(e)))
        .toList();
    return DocumentSubmissionParticipant(
      userId: j['userId']?.toString() ?? '',
      name: j['name']?.toString() ?? '-',
      email: j['email']?.toString() ?? '',
      attemptCount: _int(j['attemptCount']) ?? subs.length,
      latestStatus: j['latestStatus']?.toString() ?? 'draft',
      submissions: subs,
    );
  }

  static DocumentSubmissionManage manageFromApi(Map<String, dynamic> data) {
    final parts = (data['participants'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map((e) => participantFromApi(Map<String, dynamic>.from(e)))
        .toList();
    return DocumentSubmissionManage(
      contentId: data['contentId']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      scoringEnabled: data['scoringEnabled'] != false,
      participants: parts,
    );
  }
}
