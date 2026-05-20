/// Implementation QuizRepository - Data Layer
/// Menghubungkan domain dan data layer

import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_local_datasource.dart';
import 'package:lms_mobile_app/src/features/lessons/data/datasources/quiz_remote_datasource.dart';
import 'package:lms_mobile_app/src/core/config/flavor_config.dart';
import 'package:lms_mobile_app/src/features/lessons/data/models/quiz_model.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/quiz_repository.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizLocalDataSource localDataSource;
  final QuizRemoteDataSource? remoteDataSource;

  const QuizRepositoryImpl({
    required this.localDataSource,
    this.remoteDataSource,
  });

  @override
  Future<Quiz> getQuizByLessonId(String lessonId) async {
    try {
      // Decide source: local dummy or remote API
      final Map<String, dynamic> quizData;
      if (FlavorConfig.instance.enableMockData || remoteDataSource == null) {
        quizData = await localDataSource.getQuizByLessonId(lessonId);
      } else {
        quizData = await remoteDataSource!.getQuizByLessonId(lessonId);
      }
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

  @override
  Future<QuizResult> submitQuiz(Quiz quiz, Map<int, int> answers) async {
    // Helper to format answers payload
    List<Map<String, dynamic>> _formatAnswers() {
      final payload = <Map<String, dynamic>>[];
      for (int i = 0; i < quiz.questions.length; i++) {
        if (!answers.containsKey(i)) continue;
        final selectedIndex = answers[i]!;
        final q = quiz.questions[i];
        final qId = q.id ?? i.toString();
        String? optionId;
        if (q.optionIds != null && selectedIndex < q.optionIds!.length) {
          optionId = q.optionIds![selectedIndex];
        }
        final map = <String, dynamic>{'question_id': qId};
        if (optionId != null) map['option_id'] = optionId;
        payload.add(map);
      }
      return payload;
    }

    // If remote datasource available and quiz has id, prefer server grading/persistence
    final payload = _formatAnswers();
    if (quiz.id != null && remoteDataSource != null) {
      try {
        final attemptId = await remoteDataSource!.startQuizAttempt(quiz.id!);
        final data = await remoteDataSource!.submitQuizAttempt(
          quiz.id!,
          attemptId,
          payload,
        );
        final score = (data['score'] as num?)?.toInt() ?? 0;
        final total = (data['total'] as num?)?.toInt() ?? quiz.totalQuestions;
        return QuizResult(score: score, total: total);
      } catch (_) {
        // fallthrough to client-side grading
      }
    }

    // Client-side grading fallback
    int correctCount = 0;
    for (int i = 0; i < quiz.totalQuestions; i++) {
      if (answers.containsKey(i) &&
          answers[i] == quiz.questions[i].correctIndex) {
        correctCount++;
      }
    }

    return QuizResult(score: correctCount, total: quiz.totalQuestions);
  }
}
