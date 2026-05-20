import 'package:lms_mobile_app/src/features/lessons/data/models/quiz_model.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/quiz_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';

class SubmitQuizUseCase {
  final QuizRepository repository;
  final LessonResultRepository? resultRepository;

  SubmitQuizUseCase({required this.repository, this.resultRepository});

  Future<QuizResult> call(
    String courseId,
    String courseTitle,
    String lessonId,
    String lessonTitle,
    Quiz quiz,
    Map<int, int> answers,
  ) async {
    final result = await repository.submitQuiz(quiz, answers);

    // Persist local attempt history if repository provided
    if (resultRepository != null) {
      try {
        final questions = quiz.questions.asMap().entries.map((entry) {
          return LessonAttemptQuestionSnapshot(
            questionIndex: entry.key,
            questionText: entry.value.text,
            options: List<String>.from(entry.value.options),
            correctOptionIndex: entry.value.correctIndex,
            selectedOptionIndex: answers[entry.key],
          );
        }).toList();

        await resultRepository!.recordQuizAttempt(
          courseId: courseId,
          courseTitle: courseTitle,
          lessonId: lessonId,
          lessonTitle: lessonTitle,
          questions: questions,
          score: result.score,
          maxScore: result.total,
          passed: result.percentage >= QuizResult.passingScore,
        );
      } catch (_) {}
    }

    return result;
  }
}
