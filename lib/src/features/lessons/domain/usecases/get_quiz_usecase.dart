// GetQuizUseCase - Domain Layer
// Mengenkapsulasi business logic untuk mendapatkan quiz

import 'package:lms_mobile_app/src/features/lessons/domain/entities/quiz_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/quiz_repository.dart';

class GetQuizUseCase {
  final QuizRepository repository;

  const GetQuizUseCase({required this.repository});

  /// Execute - Dapatkan quiz berdasarkan lesson ID
  Future<Quiz> call(String lessonId) async {
    return await repository.getQuizByLessonId(lessonId);
  }

  Quiz? peekCached(String lessonId) {
    return repository.getCachedQuizByLessonId(lessonId);
  }

  /// Buang cache quiz lesson ini agar pemuatan berikutnya menarik status
  /// terbaru dari server (mis. setelah submit, agar quiz yang lulus terkunci).
  void invalidate(String lessonId) {
    repository.invalidateCachedQuiz(lessonId);
  }
}
