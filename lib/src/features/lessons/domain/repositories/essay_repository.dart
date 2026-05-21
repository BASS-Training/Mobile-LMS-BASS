import '../entities/essay_question_entity.dart';

abstract class EssayRepository {
  Future<List<EssayQuestionEntity>> getQuestions(
    String lessonId,
    String content,
  );
  Map<int, String> getDraftAnswers(String lessonId);
  Future<void> saveDraftAnswer(
    String lessonId,
    int questionIndex,
    String answer,
  );
  Future<void> submitEssayAnswers(
    String lessonId,
    List<EssayQuestionEntity> questions,
    Map<int, String> answers, {
    String? userEmail,
  });
}
