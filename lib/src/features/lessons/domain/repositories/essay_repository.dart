abstract class EssayRepository {
  List<String> getQuestions(String lessonId, String content);
  Map<int, String> getDraftAnswers(String lessonId);
  Future<void> saveDraftAnswer(String lessonId, int questionIndex, String answer);
  Future<void> submitEssayAnswers(String lessonId, Map<int, String> answers);
}