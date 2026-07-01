import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/quiz_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/quiz_repository.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/quiz_leaderboard_card.dart';

/// Bagian papan peringkat yang bisa berdiri sendiri untuk halaman "Nilai &
/// Hasil Quiz". Diberi [lessonId] (== content.id), ia me-resolve kuis untuk
/// mendapat quizId + apakah leaderboard diaktifkan, lalu mengambil papan
/// peringkatnya. Bila leaderboard nonaktif / kosong / gagal, tidak menampilkan
/// apa pun (tanpa mengganggu layout).
class QuizLeaderboardSection extends StatefulWidget {
  final String lessonId;

  const QuizLeaderboardSection({super.key, required this.lessonId});

  @override
  State<QuizLeaderboardSection> createState() => _QuizLeaderboardSectionState();
}

class _QuizLeaderboardSectionState extends State<QuizLeaderboardSection> {
  late final Future<QuizLeaderboard?> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<QuizLeaderboard?> _load() async {
    final repo = GetIt.instance<QuizRepository>();
    try {
      final quiz = await repo.getQuizByLessonId(widget.lessonId);
      if (!quiz.enableLeaderboard || quiz.id == null) return null;
      return await repo.getLeaderboard(quiz.id!);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuizLeaderboard?>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (data == null || data.entries.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: QuizLeaderboardCard(leaderboard: data),
        );
      },
    );
  }
}
