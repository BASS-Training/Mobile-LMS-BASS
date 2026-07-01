// GetQuizLeaderboardUseCase - Domain Layer
// Mengambil papan peringkat kuis (hanya bila admin mengaktifkan leaderboard).

import 'package:lms_mobile_app/src/features/lessons/domain/entities/quiz_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/quiz_repository.dart';

class GetQuizLeaderboardUseCase {
  final QuizRepository repository;

  const GetQuizLeaderboardUseCase({required this.repository});

  Future<QuizLeaderboard> call(String quizId) {
    return repository.getLeaderboard(quizId);
  }
}
