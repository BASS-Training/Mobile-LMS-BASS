import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/quiz_result/quiz_result_bloc.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz_result/quiz_attempt_history_chips.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz_result/quiz_hero_card.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz_result/quiz_performance_overview.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz_result/quiz_question_review_item.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/quiz/quiz_leaderboard_section.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

class QuizResultDetailScreen extends StatefulWidget {
  final LessonAttempt attempt;

  const QuizResultDetailScreen({super.key, required this.attempt});

  @override
  State<QuizResultDetailScreen> createState() => _QuizResultDetailScreenState();
}

class _QuizResultDetailScreenState extends State<QuizResultDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuizResultBloc>().add(
      FetchQuizResultEvent(
        courseId: widget.attempt.courseId,
        lessonId: widget.attempt.lessonId,
        initialAttempt: widget.attempt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuizResultBloc, QuizResultState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const BrandAppBar(title: 'Detail Hasil Quiz'),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.surface, AppColors.background],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: _buildBody(context, state),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, QuizResultState state) {
    if (state is QuizResultInitial || state is QuizResultLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is QuizResultFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.charcoal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final loadedState = state as QuizResultLoaded;
    final selectedAttempt = loadedState.selectedAttempt;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuizHeroCard(attempt: selectedAttempt),
          const SizedBox(height: 16),
          if (loadedState.attempts.length > 1)
            QuizAttemptHistoryChips(
              attempts: loadedState.attempts,
              selectedAttemptId: loadedState.selectedAttemptId,
              onSelected: (attempt) {
                context.read<QuizResultBloc>().add(
                  SelectQuizAttemptEvent(attemptId: attempt.id),
                );
              },
            ),
          if (loadedState.attempts.length > 1) const SizedBox(height: 16),
          _animatedSection(
            keyLabel: 'summary-${selectedAttempt.id}',
            delayMs: 360,
            child: QuizPerformanceOverview(attempt: selectedAttempt),
          ),
          const SizedBox(height: 16),
          // Papan peringkat (bila admin mengaktifkan leaderboard untuk kuis ini).
          if (selectedAttempt.lessonType == 'quiz')
            QuizLeaderboardSection(lessonId: selectedAttempt.lessonId),
          _animatedSection(
            keyLabel: 'review-header-${selectedAttempt.id}',
            delayMs: 180,
            child: Row(
              children: [
                Text(
                  'Tinjauan Jawaban',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.charcoal,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.brandText.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${selectedAttempt.questions.length} soal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.brandText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _animatedSection(
            keyLabel: 'review-${selectedAttempt.id}',
            delayMs: 480,
            child: Column(
              children: selectedAttempt.questions
                  .map((question) => QuizQuestionReviewItem(question: question))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedSection({
    required String keyLabel,
    required Widget child,
    int delayMs = 0,
  }) {
    return TweenAnimationBuilder<double>(
      key: ValueKey<String>(keyLabel),
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 340 + delayMs),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) {
        final eased = Curves.easeOut.transform(value);
        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, 28 * (1 - eased)),
            child: child,
          ),
        );
      },
    );
  }
}
