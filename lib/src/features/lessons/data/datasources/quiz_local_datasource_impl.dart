/// Implementation QuizLocalDataSource - Data Layer
/// Menggunakan QuizDummyData sebagai sumber data

import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_dummy_data.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_local_datasource.dart';

class QuizLocalDataSourceImpl implements QuizLocalDataSource {
  const QuizLocalDataSourceImpl();

  @override
  Future<Map<String, dynamic>> getQuizByLessonId(String lessonId) async {
    try {
      // Get quiz dari dummy data
      final quiz = QuizDummyData.getQuizByLessonId(lessonId);

      // Convert to map (untuk memudahkan JSON serialization ke depan)
      return {
        'title': quiz.title,
        'totalQuestions': quiz.totalQuestions,
        'timeLimit': quiz.timeLimit,
        'passingScore': quiz.passingScore,
        'questions': quiz.questions
            .map(
              (q) => {
                'text': q.text,
                'options': q.options,
                'correctIndex': q.correctIndex,
              },
            )
            .toList(),
      };
    } catch (e) {
      throw Exception('Failed to load quiz: $e');
    }
  }
}
