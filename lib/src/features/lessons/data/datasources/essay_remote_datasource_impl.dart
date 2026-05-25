import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/utils/offline_test_mode.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/essay_remote_datasource.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/essay_question_entity.dart';

class EssayRemoteDataSourceImpl implements EssayRemoteDataSource {
  final Dio dio;

  EssayRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<EssayQuestionEntity>> getQuestionsByLessonId(
    String lessonId,
  ) async {
    try {
      print(
        '[ESSAY][REMOTE][GET] lessonId=$lessonId tester=${OfflineTestMode.describeContext()}',
      );
      if (OfflineTestMode.isActive()) {
        print('[ESSAY][REMOTE][GET] blocked by tester mode');
        return const [];
      }

      final endpoint = ApiEndpoints.getEssayByLesson.replaceFirst(
        '{id}',
        lessonId,
      );
      final response = await dio.get(endpoint);
      final jsonResp = response.data as Map<String, dynamic>;
      final data = jsonResp['data'] as Map<String, dynamic>;
      final questions = (data['questions'] as List<dynamic>? ?? const []);

      return questions
          .whereType<Map<String, dynamic>>()
          .map(
            (question) => EssayQuestionEntity(
              id: question['id']?.toString() ?? '',
              text: question['text']?.toString() ?? '',
              order: (question['order'] as num?)?.toInt() ?? 0,
              maxScore: (question['maxScore'] as num?)?.toInt() ?? 1,
            ),
          )
          .where(
            (question) => question.id.isNotEmpty && question.text.isNotEmpty,
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error, 'Gagal memuat soal essay'));
    }
  }

  @override
  Future<Map<String, dynamic>> submitEssayAnswers({
    required String lessonId,
    required List<Map<String, dynamic>> answers,
    String? userEmail,
  }) async {
    print(
      '[ESSAY][REMOTE][SUBMIT] lessonId=$lessonId tester=${OfflineTestMode.describeContext()}',
    );
    if (OfflineTestMode.isActive()) {
      print('[ESSAY][REMOTE][SUBMIT] blocked by tester mode');
      return <String, dynamic>{};
    }

    final endpoint = ApiEndpoints.submitEssay.replaceFirst('{id}', lessonId);
    try {
      final response = await dio.post(endpoint, data: {'answers': answers});

      final jsonResp = response.data as Map<String, dynamic>;
      return jsonResp['data'] as Map<String, dynamic>;
    } on DioException catch (error) {
      throw Exception(
        _extractErrorMessage(error, 'Gagal mengirim jawaban essay'),
      );
    }
  }

  String _extractErrorMessage(DioException error, String fallback) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString().trim();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }

    return fallback;
  }
}
