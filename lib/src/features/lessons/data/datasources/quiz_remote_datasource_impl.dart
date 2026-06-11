import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/utils/app_logger.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/utils/offline_test_mode.dart';
import 'quiz_remote_datasource.dart';

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final Dio dio;

  QuizRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> startQuizAttempt(String quizId) async {
    logDebug(
      '[QUIZ][REMOTE][START] quizId=$quizId tester=${OfflineTestMode.describeContext()}',
    );
    if (OfflineTestMode.isActive()) {
      logDebug('[QUIZ][REMOTE][START] blocked by tester mode');
      return '';
    }

    final startEndpoint = ApiEndpoints.startQuizAttempt.replaceFirst(
      '{quiz}',
      quizId,
    );
    try {
      final startResp = await dio.post(startEndpoint);
      final jsonResponse = startResp.data as Map<String, dynamic>;
      final data = jsonResponse['data'];
      if (data is Map<String, dynamic>) {
        return data['attemptId']?.toString() ?? '';
      }
      return '';
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error, 'Start attempt failed'));
    }
  }

  @override
  Future<Map<String, dynamic>> getQuizByLessonId(String lessonId) async {
    logDebug(
      '[QUIZ][REMOTE][GET] lessonId=$lessonId tester=${OfflineTestMode.describeContext()}',
    );
    if (OfflineTestMode.isActive()) {
      logDebug('[QUIZ][REMOTE][GET] blocked by tester mode');
      return {
        'title': '',
        'totalQuestions': 0,
        'timeLimit': 0,
        'passingScore': 0,
        'questions': const [],
      };
    }

    final endpoint = ApiEndpoints.getQuizByLesson.replaceFirst(
      '{id}',
      lessonId,
    );
    try {
      final response = await dio.get(endpoint);
      final jsonResp = response.data as Map<String, dynamic>;
      final data = jsonResp['data'] as Map<String, dynamic>;
      final rawQuestions = data['questions'];
      final questions = rawQuestions is List ? rawQuestions : const [];
      final userAttempt = data['userAttempt'];
      final completed = data['completed'] ?? false;

      return {
        'id': data['id'] ?? data['quizId'] ?? data['id'],
        'title': data['title'] ?? '',
        'totalQuestions': data['totalQuestions'] ?? 0,
        'timeLimit': data['timeLimit'] ?? 0,
        'passingScore': data['passingScore'] ?? 0,
        'questions': questions.whereType<Map<String, dynamic>>().map((q) {
          final rawOptions = q['options'];
          final options = rawOptions is List ? rawOptions : const [];

          return {
            'id': q['id'].toString(),
            'text': q['text'],
            'options': options
                .whereType<Map<String, dynamic>>()
                .map((o) => o['text'])
                .toList(),
            'optionIds': options
                .whereType<Map<String, dynamic>>()
                .map((o) => o['id'].toString())
                .toList(),
            'correctIndex': q.containsKey('correctIndex')
                ? q['correctIndex']
                : null,
          };
        }).toList(),
        'userAttempt': userAttempt is Map<String, dynamic> ? userAttempt : null,
        'completed': completed == true,
      };
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error, 'Gagal memanggil API quiz'));
    }
  }

  @override
  Future<Map<String, dynamic>> submitQuizAttempt(
    String quizId,
    String attemptId,
    List<Map<String, dynamic>> answers,
  ) async {
    logDebug(
      '[QUIZ][REMOTE][SUBMIT] quizId=$quizId attemptId=$attemptId tester=${OfflineTestMode.describeContext()}',
    );
    if (OfflineTestMode.isActive()) {
      logDebug('[QUIZ][REMOTE][SUBMIT] blocked by tester mode');
      return <String, dynamic>{};
    }

    final submitEndpoint = ApiEndpoints.submitQuizAttempt
        .replaceFirst('{quiz}', quizId)
        .replaceFirst('{attempt}', attemptId);
    try {
      final submitResp = await dio.post(
        submitEndpoint,
        data: {'answers': answers},
      );
      final jsonResponse = submitResp.data as Map<String, dynamic>;
      return jsonResponse['data'] as Map<String, dynamic>;
    } on DioException catch (error) {
      throw Exception(_extractErrorMessage(error, 'Submit failed'));
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