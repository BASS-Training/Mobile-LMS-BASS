import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/feedback_remote_datasource.dart';
import 'package:lms_mobile_app/src/features/lessons/data/models/feedback_model.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/feedback_entity.dart';

class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final Dio dio;

  FeedbackRemoteDataSourceImpl({required this.dio});

  @override
  Future<FeedbackEntity> getByLesson(String lessonId) async {
    final endpoint = ApiEndpoints.getFeedbackByLesson.replaceFirst(
      '{id}',
      lessonId,
    );
    try {
      final response = await dio.get(endpoint);
      final jsonResp = response.data as Map<String, dynamic>;
      final data = Map<String, dynamic>.from(jsonResp['data'] as Map);
      return FeedbackModel.fromApi(data);
    } on DioException catch (error) {
      throw Exception(_msg(error, 'Gagal memuat form feedback'));
    }
  }

  @override
  Future<FeedbackSubmissionEntity> submit(
    String lessonId,
    Map<String, dynamic> answers,
  ) async {
    final endpoint = ApiEndpoints.submitFeedback.replaceFirst('{id}', lessonId);
    try {
      final response = await dio.post(endpoint, data: {'answers': answers});
      final jsonResp = response.data as Map<String, dynamic>;
      final data = jsonResp['data'] is Map
          ? Map<String, dynamic>.from(jsonResp['data'])
          : <String, dynamic>{};
      return FeedbackSubmissionEntity(
        submissionId: data['submissionId']?.toString() ?? '',
        status: data['status']?.toString() ?? 'submitted',
        submittedAt: DateTime.now().toIso8601String(),
      );
    } on DioException catch (error) {
      throw Exception(_msg(error, 'Gagal mengirim tanggapan'));
    }
  }

  String _msg(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString().trim();
      if (message != null && message.isNotEmpty) return message;
    }
    return fallback;
  }
}
