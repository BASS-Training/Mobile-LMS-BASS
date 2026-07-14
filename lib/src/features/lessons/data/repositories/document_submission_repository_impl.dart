import 'package:lms_mobile_app/src/features/lessons/data/datasources/document_submission_remote_datasource.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/document_submission_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/document_submission_repository.dart';

class DocumentSubmissionRepositoryImpl implements DocumentSubmissionRepository {
  final DocumentSubmissionRemoteDataSource remoteDataSource;

  DocumentSubmissionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DocumentSubmissionData> getByLesson(String lessonId) =>
      remoteDataSource.getByLesson(lessonId);

  @override
  Future<DocumentSubmissionData> uploadFile(String lessonId, String filePath) =>
      remoteDataSource.uploadFile(lessonId, filePath);

  @override
  Future<DocumentSubmissionData> removeFile(String lessonId) =>
      remoteDataSource.removeFile(lessonId);

  @override
  Future<DocumentSubmissionData> submit(String lessonId) =>
      remoteDataSource.submit(lessonId);

  @override
  Future<DocumentSubmissionManage> manage(String contentId) =>
      remoteDataSource.manage(contentId);

  @override
  Future<void> grade(
    String submissionId, {
    required String result,
    int? score,
    String? feedback,
  }) =>
      remoteDataSource.grade(
        submissionId,
        result: result,
        score: score,
        feedback: feedback,
      );
}
