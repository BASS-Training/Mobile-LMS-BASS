import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';
import 'package:lms_mobile_app/src/features/instructor/domain/entities/instructor_entities.dart';
import 'package:lms_mobile_app/src/features/lessons/data/models/case_study_model.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/case_study_entity.dart';

/// A case-study submission prepared for instructor review: the parsed template
/// + the participant's answers (reusing the participant-side parser), plus who
/// submitted it.
class CaseStudyReview {
  final String participantName;
  final bool scoringEnabled;
  final CaseStudyEntity caseStudy;

  const CaseStudyReview({
    required this.participantName,
    required this.scoringEnabled,
    required this.caseStudy,
  });
}

/// Data access for instructor / admin grading & progress (mobile).
///
/// Talks to the `/mobile/...` instructor endpoints which write to the same
/// tables as the web grading screens, so grades sync both ways.
class InstructorRepository {
  final Dio _dio;

  InstructorRepository({required Dio dio}) : _dio = dio;

  Future<List<ParticipantProgress>> getParticipants(String courseId) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.courseParticipants.replaceAll('{id}', courseId),
      );
      return _list(res.data)
          .whereType<Map>()
          .map((e) => ParticipantProgress.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal memuat daftar peserta'));
    }
  }

  Future<List<GradingQueueItem>> getGradingQueue(String courseId) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.courseGradingQueue.replaceAll('{id}', courseId),
      );
      return _list(res.data)
          .whereType<Map>()
          .map((e) => GradingQueueItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal memuat antrian penilaian'));
    }
  }

  Future<EssaySubmissionDetail> getEssaySubmission(String submissionId) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.essaySubmissionDetail.replaceAll('{id}', submissionId),
      );
      return EssaySubmissionDetail.fromJson(_map(res.data));
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal memuat jawaban essay'));
    }
  }

  /// Submit an essay grade. The body shape follows the content's mode:
  /// - overall: { overallScore?, overallFeedback? }
  /// - individual: { grades: [ {answerId, score?, feedback?} ] }
  Future<void> gradeEssay(
    String submissionId, {
    int? overallScore,
    String? overallFeedback,
    List<Map<String, dynamic>>? grades,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.gradeEssaySubmission.replaceAll('{id}', submissionId),
        data: {
          'overallScore': ?overallScore,
          'overallFeedback': ?overallFeedback,
          'grades': ?grades,
        },
      );
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal menyimpan penilaian'));
    }
  }

  Future<CaseStudyReview> getCaseStudySubmission(String submissionId) async {
    try {
      final res = await _dio.get(
        ApiEndpoints.caseStudySubmissionDetail.replaceAll('{id}', submissionId),
      );
      final data = _map(res.data);
      // Re-shape into the structure CaseStudyModel.fromApi expects so we reuse
      // the exact same template/answers parsing the participant screen uses.
      final caseStudy = CaseStudyModel.fromApi({
        'id': data['contentId'],
        'title': data['contentTitle'],
        'scoringEnabled': data['scoringEnabled'],
        'template': data['template'],
        'submission': {
          'submissionId': data['submissionId'],
          'status': data['status'],
          'answers': data['answers'],
          'score': data['score'],
          'feedback': data['feedback'],
        },
      });
      return CaseStudyReview(
        participantName: data['participantName']?.toString() ?? 'Peserta',
        scoringEnabled: data['scoringEnabled'] != false,
        caseStudy: caseStudy,
      );
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal memuat jawaban studi kasus'));
    }
  }

  Future<void> gradeCaseStudy(
    String submissionId, {
    int? score,
    String? feedback,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.gradeCaseStudySubmission.replaceAll('{id}', submissionId),
        data: {
          'score': ?score,
          'feedback': ?feedback,
        },
      );
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Gagal menyimpan penilaian'));
    }
  }

  List<dynamic> _list(dynamic body) {
    if (body is Map && body['data'] is List) return body['data'] as List;
    if (body is List) return body;
    return const [];
  }

  Map<String, dynamic> _map(dynamic body) {
    if (body is Map && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data'] as Map);
    }
    if (body is Map) return Map<String, dynamic>.from(body);
    return <String, dynamic>{};
  }
}
