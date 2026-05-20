import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lms_mobile_app/src/core/config/flavor_config.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'quiz_remote_datasource.dart';

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final http.Client client;

  QuizRemoteDataSourceImpl({required this.client});

  @override
  Future<String> startQuizAttempt(String quizId) async {
    final baseUrl = FlavorConfig.instance.apiBaseUrl;
    final startEndpoint = ApiEndpoints.startQuizAttempt.replaceFirst(
      '{quiz}',
      quizId,
    );
    final startUrl = Uri.parse('$baseUrl$startEndpoint');

    final startResp = await client.post(
      startUrl,
      headers: {'Content-Type': 'application/json'},
    );
    if (!(startResp.statusCode == 200 || startResp.statusCode == 201)) {
      throw Exception('Start attempt failed ${startResp.statusCode}');
    }
    final jsonResponse = json.decode(startResp.body) as Map<String, dynamic>;
    return jsonResponse['data']?['attemptId']?.toString() ?? '';
  }

  @override
  Future<Map<String, dynamic>> getQuizByLessonId(String lessonId) async {
    final baseUrl = FlavorConfig.instance.apiBaseUrl;
    final endpoint = ApiEndpoints.getQuizByLesson.replaceFirst(
      '{id}',
      lessonId,
    );
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await client.get(url);
    if (response.statusCode != 200) {
      // Try to extract error message from response
      String errorMessage = 'Gagal memanggil API quiz: HTTP ${response.statusCode}';
      try {
        final Map<String, dynamic> errorResp =
            json.decode(response.body) as Map<String, dynamic>;
        if (errorResp.containsKey('message')) {
          errorMessage = errorResp['message'].toString();
        }
      } catch (_) {
        // Keep default error message if response parsing fails
      }
      throw Exception(errorMessage);
    }

    final Map<String, dynamic> jsonResp =
        json.decode(response.body) as Map<String, dynamic>;
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
  }

  @override
  Future<Map<String, dynamic>> submitQuizAttempt(
    String quizId,
    String attemptId,
    List<Map<String, dynamic>> answers,
  ) async {
    final baseUrl = FlavorConfig.instance.apiBaseUrl;
    final submitEndpoint = ApiEndpoints.submitQuizAttempt
        .replaceFirst('{quiz}', quizId)
        .replaceFirst('{attempt}', attemptId);
    final submitUrl = Uri.parse('$baseUrl$submitEndpoint');

    final submitResp = await client.post(
      submitUrl,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'answers': answers}),
    );

    if (submitResp.statusCode != 200)
      throw Exception('Submit failed ${submitResp.statusCode}');
    final jsonResponse = json.decode(submitResp.body) as Map<String, dynamic>;
    return jsonResponse['data'] as Map<String, dynamic>;
  }
}
