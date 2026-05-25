import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/utils/app_date_formatter.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';

class QuizResultDetailScreen extends StatefulWidget {
  final LessonAttempt attempt;

  const QuizResultDetailScreen({super.key, required this.attempt});

  @override
  State<QuizResultDetailScreen> createState() => _QuizResultDetailScreenState();
}

class _QuizResultDetailScreenState extends State<QuizResultDetailScreen> {
  late Future<List<LessonAttempt>> _attemptsFuture;
  late LessonAttempt _selectedAttempt;

  @override
  void initState() {
    super.initState();
    _selectedAttempt = widget.attempt;
    _attemptsFuture = GetIt.instance<LessonResultRepository>()
        .getAttemptsByLesson(
          courseId: widget.attempt.courseId,
          lessonId: widget.attempt.lessonId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        title: const Text('Detail Hasil Quiz'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.red, AppColors.tomato],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFF), Color(0xFFF1F4FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<List<LessonAttempt>>(
          future: _attemptsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final attempts = snapshot.data ?? <LessonAttempt>[];
            if (attempts.isNotEmpty) {
              _selectedAttempt = attempts.firstWhere(
                (attempt) => attempt.id == _selectedAttempt.id,
                orElse: () => attempts.first,
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(child: _buildHeroCard(_selectedAttempt)),
                  const SizedBox(height: 16),
                  if (attempts.length > 1)
                    FadeSlideIn(
                      delayMs: 60,
                      child: _buildHistoryChips(attempts),
                    ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    delayMs: 100,
                    child: _buildSummaryCards(_selectedAttempt),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    delayMs: 130,
                    child: _buildOverviewBanner(_selectedAttempt),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tinjauan Jawaban',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._selectedAttempt.questions.map(_buildQuestionReview),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroCard(LessonAttempt attempt) {
    final passed = attempt.passed == true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: passed
              ? [const Color(0xFF79E5A9), const Color(0xFF8ED8F1)]
              : [const Color(0xFFFFB36B), const Color(0xFFFFD36B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.info,
            color: Colors.white,
            size: 54,
          ),
          const SizedBox(height: 10),
          Text(
            passed ? 'Selamat! Anda Lulus' : 'Belum Lulus',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${attempt.lessonTitle} • ${attempt.attemptLabel}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryChips(List<LessonAttempt> attempts) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attempts.length,
        separatorBuilder: (context, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final attempt = attempts[index];
          final isSelected = attempt.id == _selectedAttempt.id;
          return ChoiceChip(
            selected: isSelected,
            label: Text(attempt.attemptLabel),
            onSelected: (_) {
              setState(() {
                _selectedAttempt = attempt;
              });
            },
            selectedColor: AppColors.red.withValues(alpha: 0.16),
            labelStyle: TextStyle(
              color: isSelected ? AppColors.red : AppColors.slate,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(LessonAttempt attempt) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Nilai',
            '${attempt.percentage.toStringAsFixed(0)}%',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Benar',
            attempt.score?.toStringAsFixed(0) ?? '0',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total',
            attempt.maxScore?.toStringAsFixed(0) ?? '0',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.slate),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewBanner(LessonAttempt attempt) {
    final passed = attempt.passed == true;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: passed ? Colors.green[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: passed ? Colors.green[200]! : Colors.orange[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            passed ? Icons.verified : Icons.info,
            color: passed ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dikerjakan pada ${formatAppDateTime(attempt.submittedAt)} • ${attempt.attemptLabel}',
              style: TextStyle(
                color: passed ? Colors.green[800] : Colors.orange[800],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionReview(LessonAttemptQuestionSnapshot question) {
    final selectedIndex = question.selectedOptionIndex;
    final correctIndex = question.correctOptionIndex;
    final isAnsweredCorrectly =
        selectedIndex != null && selectedIndex == correctIndex;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Soal ${question.questionIndex + 1}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.red,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 14),
          ...question.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final optionText = entry.value;
            final isSelected = selectedIndex == optionIndex;
            final isCorrect = correctIndex == optionIndex;
            final label = isSelected && isCorrect
                ? 'Jawaban Anda Benar'
                : isSelected && !isAnsweredCorrectly
                ? 'Jawaban Anda Salah'
                : isCorrect
                ? 'Kunci Jawaban'
                : '';
            final iconClass = isSelected && isCorrect
                ? Icons.check_circle
                : isSelected && !isAnsweredCorrectly
                ? Icons.close
                : isCorrect
                ? Icons.lightbulb
                : null;

            final backgroundColor = isCorrect
                ? Colors.green.withValues(alpha: 0.14)
                : isSelected
                ? Colors.red.withValues(alpha: 0.12)
                : Colors.grey.withValues(alpha: 0.05);
            final borderColor = isCorrect
                ? Colors.green
                : isSelected
                ? Colors.red
                : Colors.transparent;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green
                          : isSelected
                          ? Colors.red
                          : AppColors.pearl,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + optionIndex),
                        style: TextStyle(
                          color: isCorrect || isSelected
                              ? Colors.white
                              : AppColors.charcoal,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      optionText,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  if (label.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? Colors.green.withValues(alpha: 0.12)
                            : Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            iconClass ?? Icons.circle,
                            size: 12,
                            color: isCorrect ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            label,
                            style: TextStyle(
                              color: isCorrect ? Colors.green : Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
