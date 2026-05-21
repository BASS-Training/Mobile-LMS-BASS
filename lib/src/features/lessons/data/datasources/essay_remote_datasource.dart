import 'package:lms_mobile_app/src/features/lessons/domain/entities/essay_question_entity.dart';

abstract class EssayRemoteDataSource {
  Future<List<EssayQuestionEntity>> getQuestionsByLessonId(String lessonId);

  Future<Map<String, dynamic>> submitEssayAnswers({
    required String lessonId,
    required List<Map<String, dynamic>> answers,
    String? userEmail,
  });
}
