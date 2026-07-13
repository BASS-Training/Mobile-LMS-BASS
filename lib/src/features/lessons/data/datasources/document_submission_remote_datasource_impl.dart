import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/document_submission_remote_datasource.dart';
import 'package:lms_mobile_app/src/features/lessons/data/models/document_submission_model.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/document_submission_entity.dart';

class DocumentSubmissionRemoteDataSourceImpl
    implements DocumentSubmissionRemoteDataSource {
  final Dio dio;

  DocumentSubmissionRemoteDataSourceImpl({required this.dio});

  String _basename(String path) => path.split(RegExp(r'[/\\]')).last;

  Map<String, dynamic> _data(Response response) {
    final json = response.data as Map<String, dynamic>;
    return json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : <String, dynamic>{};
  }

  @override
  Future<DocumentSubmissionData> getByLesson(String lessonId) async {
    final endpoint = ApiEndpoints.getDocumentSubmission.replaceFirst(
      '{id}',
      lessonId,
    );
    try {
      final response = await dio.get(endpoint);
      return DocumentSubmissionModel.fromApi(_data(response));
    } on DioException catch (error) {
      throw Exception(dioErrorMessage(error, 'Gagal memuat pengumpulan'));
    }
  }

  @override
  Future<DocumentSubmissionData> uploadFile(
    String lessonId,
    String filePath,
  ) async {
    final endpoint = ApiEndpoints.uploadDocumentSubmission.replaceFirst(
      '{id}',
      lessonId,
    );
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: _basename(filePath),
        ),
      });
      await dio.post(endpoint, data: formData);
      // API mengembalikan attempt tunggal; ambil ulang state lengkap.
      return getByLesson(lessonId);
    } on DioException catch (error) {
      throw Exception(dioErrorMessage(error, 'Gagal mengunggah file'));
    }
  }

  @override
  Future<DocumentSubmissionData> removeFile(String lessonId) async {
    final endpoint = ApiEndpoints.removeDocumentSubmissionFile.replaceFirst(
      '{id}',
      lessonId,
    );
    try {
      await dio.delete(endpoint);
      return getByLesson(lessonId);
    } on DioException catch (error) {
      throw Exception(dioErrorMessage(error, 'Gagal menghapus file'));
    }
  }

  @override
  Future<DocumentSubmissionData> submit(String lessonId) async {
    final endpoint = ApiEndpoints.submitDocumentSubmission.replaceFirst(
      '{id}',
      lessonId,
    );
    try {
      await dio.post(endpoint);
      return getByLesson(lessonId);
    } on DioException catch (error) {
      throw Exception(dioErrorMessage(error, 'Gagal mengumpulkan tugas'));
    }
  }

  @override
  Future<DocumentSubmissionManage> manage(String contentId) async {
    final endpoint = ApiEndpoints.manageDocumentSubmissions.replaceFirst(
      '{id}',
      contentId,
    );
    try {
      final response = await dio.get(endpoint);
      return DocumentSubmissionModel.manageFromApi(_data(response));
    } on DioException catch (error) {
      throw Exception(dioErrorMessage(error, 'Gagal memuat pengumpulan'));
    }
  }

  @override
  Future<void> grade(
    String submissionId, {
    required String result,
    int? score,
    String? feedback,
  }) async {
    final endpoint = ApiEndpoints.gradeDocumentSubmission.replaceFirst(
      '{id}',
      submissionId,
    );
    try {
      await dio.post(
        endpoint,
        data: {
          'result': result,
          'score': ?score,
          'feedback': ?feedback,
        },
      );
    } on DioException catch (error) {
      throw Exception(dioErrorMessage(error, 'Gagal menyimpan penilaian'));
    }
  }
}
