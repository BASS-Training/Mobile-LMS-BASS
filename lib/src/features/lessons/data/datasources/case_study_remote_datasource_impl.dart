import 'dart:typed_data';
import 'package:lms_mobile_app/src/core/network/dio_error.dart';

import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/case_study_remote_datasource.dart';
import 'package:lms_mobile_app/src/features/lessons/data/models/case_study_model.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/case_study_entity.dart';

class CaseStudyRemoteDataSourceImpl implements CaseStudyRemoteDataSource {
  final Dio dio;

  CaseStudyRemoteDataSourceImpl({required this.dio});

  @override
  Future<CaseStudyEntity> getByLesson(String lessonId) async {
    final endpoint = ApiEndpoints.getCaseStudyByLesson.replaceFirst(
      '{id}',
      lessonId,
    );
    try {
      final response = await dio.get(endpoint);
      final jsonResp = response.data as Map<String, dynamic>;
      final data = Map<String, dynamic>.from(jsonResp['data'] as Map);
      return CaseStudyModel.fromApi(data);
    } on DioException catch (error) {
      throw Exception(dioErrorMessage(error, 'Gagal memuat studi kasus'));
    }
  }

  @override
  Future<CaseStudySubmissionEntity> submit(
    String lessonId,
    Map<String, dynamic> answers,
  ) async {
    final endpoint = ApiEndpoints.submitCaseStudy.replaceFirst(
      '{id}',
      lessonId,
    );
    try {
      final response = await dio.post(endpoint, data: {'answers': answers});
      final jsonResp = response.data as Map<String, dynamic>;
      final data = jsonResp['data'] is Map
          ? Map<String, dynamic>.from(jsonResp['data'])
          : <String, dynamic>{};
      return CaseStudySubmissionEntity(
        submissionId: data['submissionId']?.toString() ?? '',
        status: data['status']?.toString() ?? 'submitted',
        answers: answers,
      );
    } on DioException catch (error) {
      throw Exception(dioErrorMessage(error, 'Gagal mengumpulkan jawaban'));
    }
  }

  @override
  Future<void> saveDraft(String lessonId, Map<String, dynamic> answers) async {
    final endpoint = ApiEndpoints.autosaveCaseStudy.replaceFirst(
      '{id}',
      lessonId,
    );
    try {
      await dio.post(endpoint, data: {'answers': answers});
    } on DioException catch (error) {
      throw Exception(dioErrorMessage(error, 'Gagal menyimpan draft'));
    }
  }

  @override
  Future<Uint8List> downloadPdf(String lessonId) async {
    final endpoint = ApiEndpoints.downloadCaseStudy.replaceFirst(
      '{id}',
      lessonId,
    );
    try {
      final response = await dio.get<List<int>>(
        endpoint,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data ?? const []);
    } on DioException catch (error) {
      throw Exception(dioErrorMessage(error, 'Gagal mengunduh PDF'));
    }
  }
}
