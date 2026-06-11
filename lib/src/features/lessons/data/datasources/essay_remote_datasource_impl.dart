import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/utils/app_logger.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/utils/offline_test_mode.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/essay_remote_datasource.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/essay_question_entity.dart';

class EssayRemoteDataSourceImpl implements EssayRemoteDataSource {
  final Dio dio;

  EssayRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<EssayQuestionEntity>> getQuestionsByLessonId(
    String lessonId,
  ) async {
    try {
      logDebug(
        '[ESSAY][REMOTE][GET] lessonId=$lessonId tester=${OfflineTestMode.describeContext()}',
      );
      if (OfflineTestMode.isActive()) {
        logDebug('[ESSAY][REMOTE][GET] blocked by tester mode');
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

      // if user already has a submitted submission, mark lesson complete locally
      final submission = data['submission'];
      if (submission is Map<String, dynamic> &&
          submission['status'] == 'submitted') {
        try {
          await LocalStorage.markEssaySubmitted(lessonId);
          await LocalStorage.markLessonComplete(lessonId);
        } catch (_) {}
      }

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
  Future<Map<String, String>> getDraftAnswersByLessonId(String lessonId) async {
    if (OfflineTestMode.isActive()) {
      return <String, String>{};
    }

    final endpoint = ApiEndpoints.getEssayByLesson.replaceFirst(
      '{id}',
      lessonId,
    );
    try {
      final response = await dio.get(endpoint);
      final jsonResp = response.data as Map<String, dynamic>;
      final data = jsonResp['data'] as Map<String, dynamic>;
      final submission = data['submission'];

      if (submission is! Map<String, dynamic>) {
        return <String, String>{};
      }

      final answers = submission['answers'];
      if (answers is! List) {
        return <String, String>{};
      }

      final result = <String, String>{};
      for (final item in answers.whereType<Map<String, dynamic>>()) {
        final questionId = item['question_id']?.toString().trim() ?? '';
        final answer = item['answer']?.toString() ?? '';
        if (questionId.isEmpty || answer.trim().isEmpty) continue;
        result[questionId] = answer;
      }

      return result;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error, 'Gagal memuat draft essay'));
    }
  }

  @override
  Future<Map<String, dynamic>> submitEssayAnswers({
    required String lessonId,
    required List<Map<String, dynamic>> answers,
    String? userEmail,
  }) async {
    logDebug(
      '[ESSAY][REMOTE][SUBMIT] lessonId=$lessonId tester=${OfflineTestMode.describeContext()}',
    );
    if (OfflineTestMode.isActive()) {
      logDebug('[ESSAY][REMOTE][SUBMIT] blocked by tester mode');
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

  @override
  Future<void> autosaveEssayDraft({
    required String lessonId,
    required List<Map<String, dynamic>> answers,
  }) async {
    logDebug(
      '[ESSAY][REMOTE][AUTOSAVE] lessonId=$lessonId tester=${OfflineTestMode.describeContext()}',
    );

    if (OfflineTestMode.isActive()) {
      logDebug('[ESSAY][REMOTE][AUTOSAVE] blocked by tester mode');
      return;
    }

    final endpoint = ApiEndpoints.autosaveEssay.replaceFirst('{id}', lessonId);
    try {
      await dio.post(endpoint, data: {'answers': answers});
      return;
    } on DioException catch (error) {
      // don't fail hard on autosave; just log or rethrow if needed
      throw Exception(
        _extractErrorMessage(error, 'Gagal menyimpan draft essay'),
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