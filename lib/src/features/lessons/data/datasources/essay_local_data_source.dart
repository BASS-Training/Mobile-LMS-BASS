import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/essay_dummy_data.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/essay_question_entity.dart';

abstract class EssayLocalDataSource {
  List<EssayQuestionEntity> getQuestions(String lessonId, String content);
  Map<int, String> getDraftAnswers(String lessonId);
  Future<void> saveDraftAnswer(
    String lessonId,
    int questionIndex,
    String answer,
  );
  Future<void> saveAllDraftAnswers(String lessonId, Map<int, String> answers);
}

class EssayLocalDataSourceImpl implements EssayLocalDataSource {
  @override
  List<EssayQuestionEntity> getQuestions(String lessonId, String content) {
    return EssayDummyData.getQuestions(lessonId);
  }

  @override
  Map<int, String> getDraftAnswers(String lessonId) {
    return LocalStorage.getEssayDraftAnswers(lessonId);
  }

  @override
  Future<void> saveDraftAnswer(
    String lessonId,
    int questionIndex,
    String answer,
  ) async {
    LocalStorage.saveEssayDraftAnswer(
      lessonId: lessonId,
      questionIndex: questionIndex,
      answer: answer,
    );
  }

  @override
  Future<void> saveAllDraftAnswers(
    String lessonId,
    Map<int, String> answers,
  ) async {
    await LocalStorage.saveEssayDraftAnswers(
      lessonId: lessonId,
      answers: answers,
    );
  }
}
