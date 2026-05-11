/// Implementation QuizRepository - Data Layer
/// Menghubungkan domain dan data layer

import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_local_datasource.dart';
import 'package:lms_mobile_app/src/features/lessons/data/models/quiz_model.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/quiz_repository.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizLocalDataSource localDataSource;

  const QuizRepositoryImpl({required this.localDataSource});

  @override
  Future<Quiz> getQuizByLessonId(String lessonId) async {
    try {
      // Get data dari local data source
      final quizData = await localDataSource.getQuizByLessonId(lessonId);

      // Convert to Quiz model
      return Quiz(
        title: quizData['title'] as String,
        totalQuestions: quizData['totalQuestions'] as int,
        timeLimit: quizData['timeLimit'] as int,
        passingScore: quizData['passingScore'] as int,
        questions: (quizData['questions'] as List<dynamic>)
            .map(
              (q) => Question(
                text: q['text'] as String,
                options: List<String>.from(q['options'] as List<dynamic>),
                correctIndex: q['correctIndex'] as int,
              ),
            )
            .toList(),
      );
    } catch (e) {
      throw Exception('Failed to get quiz: $e');
    }
  }
}
