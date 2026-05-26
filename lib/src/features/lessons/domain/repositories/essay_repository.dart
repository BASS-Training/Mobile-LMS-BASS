import '../entities/essay_question_entity.dart';

abstract class EssayRepository {
  Future<List<EssayQuestionEntity>> getQuestions(
    String lessonId,
    String content,
  );
  Future<Map<int, String>> getDraftAnswers(
    String lessonId,
    List<EssayQuestionEntity> questions,
  );
  Future<void> saveDraftAnswer(
    String lessonId,
    int questionIndex,
    String answer,
  );
  Future<void> syncDraftAnswers(
    String lessonId,
    List<EssayQuestionEntity> questions,
    Map<int, String> answers,
  );
  Future<void> submitEssayAnswers(
    String lessonId,
    List<EssayQuestionEntity> questions,
    Map<int, String> answers, {
    String? userEmail,
  });
}
