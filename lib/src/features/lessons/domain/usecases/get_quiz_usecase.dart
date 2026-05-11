/// GetQuizUseCase - Domain Layer
/// Mengenkapsulasi business logic untuk mendapatkan quiz

import 'package:lms_mobile_app/src/features/lessons/data/models/quiz_model.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/quiz_repository.dart';

class GetQuizUseCase {
  final QuizRepository repository;

  const GetQuizUseCase({required this.repository});

  /// Execute - Dapatkan quiz berdasarkan lesson ID
  Future<Quiz> call(String lessonId) async {
    return await repository.getQuizByLessonId(lessonId);
  }
}
