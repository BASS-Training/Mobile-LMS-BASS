import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/essay_dummy_data.dart';

abstract class EssayLocalDataSource {
  List<String> getQuestions(String lessonId, String content);
  Map<int, String> getDraftAnswers(String lessonId);
  Future<void> saveDraftAnswer(String lessonId, int questionIndex, String answer);
  Future<void> saveAllDraftAnswers(String lessonId, Map<int, String> answers);
}

class EssayLocalDataSourceImpl implements EssayLocalDataSource {
  @override
  List<String> getQuestions(String lessonId, String content) {
    return EssayDummyData.getQuestions(lessonId, content);
  }

  @override
  Map<int, String> getDraftAnswers(String lessonId) {
    return LocalStorage.getEssayDraftAnswers(lessonId);
  }

  @override
  Future<void> saveDraftAnswer(String lessonId, int questionIndex, String answer) async {
    LocalStorage.saveEssayDraftAnswer(
      lessonId: lessonId,
      questionIndex: questionIndex,
      answer: answer,
    );
  }

  @override
  Future<void> saveAllDraftAnswers(String lessonId, Map<int, String> answers) async {
    await LocalStorage.saveEssayDraftAnswers(
      lessonId: lessonId,
      answers: answers,
    );
  }
}