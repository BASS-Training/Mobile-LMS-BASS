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
      final baseQuestions = (quizData['questions'] as List<dynamic>)
          .map(
            (q) => Question(
              text: q['text'] as String,
              options: List<String>.from(q['options'] as List<dynamic>),
              correctIndex: q['correctIndex'] as int,
            ),
          )
          .toList();

      final expandedQuestions = _expandQuestions(baseQuestions, 30);

      // Convert to Quiz model
      return Quiz(
        title: quizData['title'] as String,
        totalQuestions: expandedQuestions.length,
        timeLimit: quizData['timeLimit'] as int,
        passingScore: quizData['passingScore'] as int,
        questions: expandedQuestions,
      );
    } catch (e) {
      throw Exception('Failed to get quiz: $e');
    }
  }

  List<Question> _expandQuestions(
    List<Question> baseQuestions,
    int targetCount,
  ) {
    if (baseQuestions.isEmpty) return baseQuestions;
    if (baseQuestions.length >= targetCount) return baseQuestions;

    final expanded = <Question>[];
    var round = 0;

    while (expanded.length < targetCount) {
      round++;
      for (
        var i = 0;
        i < baseQuestions.length && expanded.length < targetCount;
        i++
      ) {
        final question = baseQuestions[i];
        expanded.add(
          Question(
            text: '${question.text} (Bagian $round)',
            options: question.options,
            correctIndex: question.correctIndex,
          ),
        );
      }
    }

    return expanded;
  }
}
