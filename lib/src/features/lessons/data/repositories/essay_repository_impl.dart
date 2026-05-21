import 'package:lms_mobile_app/src/core/config/flavor_config.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/essay_remote_datasource.dart';
import '../../domain/repositories/essay_repository.dart';
import '../datasources/essay_local_data_source.dart';
import '../../domain/entities/essay_question_entity.dart';

class EssayRepositoryImpl implements EssayRepository {
  final EssayLocalDataSource localDataSource;
  final EssayRemoteDataSource? remoteDataSource;

  EssayRepositoryImpl(this.localDataSource, {this.remoteDataSource});

  @override
  Future<List<EssayQuestionEntity>> getQuestions(
    String lessonId,
    String content,
  ) async {
    try {
      if (!FlavorConfig.instance.enableMockData && remoteDataSource != null) {
        final questions = await remoteDataSource!.getQuestionsByLessonId(lessonId);
        if (questions.isNotEmpty) {
          return questions;
        }
      }
    } catch (_) {
      // fallback ke local dummy saat API belum tersedia
    }

    return localDataSource.getQuestions(lessonId, content);
  }

  @override
  Map<int, String> getDraftAnswers(String lessonId) {
    return localDataSource.getDraftAnswers(lessonId);
  }

  @override
  Future<void> saveDraftAnswer(String lessonId, int questionIndex, String answer) async {
    await localDataSource.saveDraftAnswer(lessonId, questionIndex, answer);
  }

  @override
  Future<void> submitEssayAnswers(
    String lessonId,
    List<EssayQuestionEntity> questions,
    Map<int, String> answers,
    {String? userEmail}
  ) async {
    final payload = <Map<String, dynamic>>[];
    for (int i = 0; i < questions.length; i++) {
      final answer = answers[i]?.trim();
      if (answer == null || answer.isEmpty) {
        continue;
      }

      payload.add({
        'question_id': questions[i].id,
        'answer': answer,
      });
    }

    if (payload.isEmpty) {
      throw Exception('Tidak ada jawaban untuk dikirim.');
    }

    if (!FlavorConfig.instance.enableMockData && remoteDataSource != null) {
      await remoteDataSource!.submitEssayAnswers(
        lessonId: lessonId,
        answers: payload,
        userEmail: userEmail,
      );
    }

    await localDataSource.saveAllDraftAnswers(lessonId, answers);
  }
}