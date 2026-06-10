/// Implementation QuizLocalDataSource - Data Layer (offline/dummy only)
library;

import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_dummy_data.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_local_datasource.dart';

class QuizLocalDataSourceImpl implements QuizLocalDataSource {
  const QuizLocalDataSourceImpl();

  @override
  Future<Map<String, dynamic>> getQuizByLessonId(String lessonId) async {
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
              'optionIds': q.optionIds,
              'correctIndex': q.correctIndex,
            },
          )
          .toList(),
    };
  }
}
