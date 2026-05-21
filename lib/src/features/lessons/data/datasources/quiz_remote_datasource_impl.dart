import 'package:dio/dio.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'quiz_remote_datasource.dart';

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final Dio dio;

  QuizRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> startQuizAttempt(String quizId) async {
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
    final endpoint = ApiEndpoints.getQuizByLesson.replaceFirst(
      '{id}',
      lessonId,
    );
    try {
      final response = await dio.get(endpoint);
      final jsonResp = response.data as Map<String, dynamic>;
      final data = jsonResp['data'] as Map<String, dynamic>;

      return {
        'title': data['title'] ?? '',
        'totalQuestions': data['totalQuestions'] ?? 0,
        'timeLimit': data['timeLimit'] ?? 0,
        'passingScore': data['passingScore'] ?? 0,
        'questions': (data['questions'] as List<dynamic>).map((q) {
          return {
            'id': q['id'].toString(),
            'text': q['text'],
            'options': (q['options'] as List<dynamic>)
                .map((o) => o['text'])
                .toList(),
            'optionIds': (q['options'] as List<dynamic>)
                .map((o) => o['id'].toString())
                .toList(),
            'correctIndex': q.containsKey('correctIndex')
                ? q['correctIndex']
                : null,
          };
        }).toList(),
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
