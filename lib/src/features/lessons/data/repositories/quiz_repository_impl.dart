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
      final baseQuestions = (quizData['questions'] as List<dynamic>).map((q) {
        final options = <String>[];
        try {
          options.addAll(List<String>.from(q['options'] as List<dynamic>));
        } catch (_) {}

        int? correct;
        if (q.containsKey('correctIndex')) {
          try {
            correct = q['correctIndex'] as int;
          } catch (_) {
            correct = null;
          }
        }

        return Question(
          id: q.containsKey('id') ? q['id'].toString() : null,
          text: q['text'] as String,
          options: options,
          optionIds: q.containsKey('optionIds')
              ? List<String>.from(q['optionIds'] as List<dynamic>)
              : null,
          correctIndex: correct,
        );
      }).toList();

      // Use questions exactly as returned from backend / database
      final questions = baseQuestions;

      // Convert to Quiz model
      return Quiz(
        id: quizData.containsKey('id') ? quizData['id'].toString() : null,
        title: quizData['title'] as String,
        totalQuestions: questions.length,
        timeLimit: quizData['timeLimit'] as int,
        passingScore: quizData['passingScore'] as int,
        questions: questions,
      );
    } catch (e) {
      throw Exception('Failed to get quiz: $e');
    }
  }
}
