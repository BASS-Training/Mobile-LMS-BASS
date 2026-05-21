import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lms_mobile_app/src/core/config/constants/api_endpoints.dart';
import 'package:lms_mobile_app/src/core/config/flavor_config.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/essay_remote_datasource.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/essay_question_entity.dart';

class EssayRemoteDataSourceImpl implements EssayRemoteDataSource {
  final http.Client client;

  EssayRemoteDataSourceImpl({required this.client});

  @override
  Future<List<EssayQuestionEntity>> getQuestionsByLessonId(
    String lessonId,
  ) async {
    final baseUrl = FlavorConfig.instance.apiBaseUrl;
    final endpoint = ApiEndpoints.getEssayByLesson.replaceFirst(
      '{id}',
      lessonId,
    );
    final url = Uri.parse('$baseUrl$endpoint');

    final response = await client.get(url);
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat soal essay: HTTP ${response.statusCode}');
    }

    final jsonResp = json.decode(response.body) as Map<String, dynamic>;
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
        .where((question) => question.id.isNotEmpty && question.text.isNotEmpty)
        .toList();
  }

  @override
  Future<Map<String, dynamic>> submitEssayAnswers({
    required String lessonId,
    required List<Map<String, dynamic>> answers,
    String? userEmail,
  }) async {
    final baseUrl = FlavorConfig.instance.apiBaseUrl;
    final endpoint = ApiEndpoints.submitEssay.replaceFirst('{id}', lessonId);
    final url = Uri.parse('$baseUrl$endpoint');

    final payload = <String, dynamic>{'answers': answers};

    final response = await client.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (LocalStorage.getAuthToken() != null)
          'Authorization': 'Bearer ${LocalStorage.getAuthToken()}',
      },
      body: json.encode(payload),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Gagal mengirim jawaban essay';
      try {
        final errorResp = json.decode(response.body) as Map<String, dynamic>;
        errorMessage = errorResp['message']?.toString() ?? errorMessage;
      } catch (_) {}
      throw Exception(errorMessage);
    }

    final jsonResp = json.decode(response.body) as Map<String, dynamic>;
    return jsonResp['data'] as Map<String, dynamic>;
  }
}
