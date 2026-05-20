/// Implementation QuizLocalDataSource - Data Layer
/// Default impl: if FlavorConfig.enableMockData == true use dummy, else fetch from API

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lms_mobile_app/src/core/config/flavor_config.dart';
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_dummy_data.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_local_datasource.dart';

class QuizLocalDataSourceImpl implements QuizLocalDataSource {
  const QuizLocalDataSourceImpl();

  @override
  Future<Map<String, dynamic>> getQuizByLessonId(String lessonId) async {
    try {
      // Jika enableMockData true, gunakan dummy lokal
      if (FlavorConfig.instance.enableMockData) {
        final quiz = QuizDummyData.getQuizByLessonId(lessonId);
        return {
          'title': quiz.title,
          'totalQuestions': quiz.totalQuestions,
          'timeLimit': quiz.timeLimit,
          'passingScore': quiz.passingScore,
          'questions': quiz.questions
              .map(
                (q) => {
                  'id': q.id,
                  'text': q.text,
                  'options': q.options,
                  'correctIndex': q.correctIndex,
                },
              )
              .toList(),
        };
      }

      // Otherwise, panggil API remote
      final baseUrl = FlavorConfig.instance.apiBaseUrl;
      final endpoint = ApiEndpoints.getQuizByLesson.replaceFirst(
        '{id}',
        lessonId,
      );
      final url = Uri.parse('$baseUrl$endpoint');

      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception(
          'Gagal memanggil API quiz: HTTP ${response.statusCode}',
        );
      }

      final Map<String, dynamic> jsonResp =
          json.decode(response.body) as Map<String, dynamic>;
      final data = jsonResp['data'] as Map<String, dynamic>;

      // Normalize to expected local shape
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
    } catch (e) {
      throw Exception('Failed to load quiz: $e');
    }
  }
}
