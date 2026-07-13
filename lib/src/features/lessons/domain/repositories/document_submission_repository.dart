import 'package:lms_mobile_app/src/features/lessons/domain/entities/document_submission_entity.dart';

abstract class DocumentSubmissionRepository {
  Future<DocumentSubmissionData> getByLesson(String lessonId);
  Future<DocumentSubmissionData> uploadFile(String lessonId, String filePath);
  Future<DocumentSubmissionData> removeFile(String lessonId);
  Future<DocumentSubmissionData> submit(String lessonId);

  Future<DocumentSubmissionManage> manage(String contentId);
  Future<void> grade(
    String submissionId, {
    required String result,
    int? score,
    String? feedback,
  });
}
