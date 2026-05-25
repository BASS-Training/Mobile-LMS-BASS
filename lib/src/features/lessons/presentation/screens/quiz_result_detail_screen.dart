import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/utils/app_date_formatter.dart';

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
                  _buildHeroCard(_selectedAttempt),
                  const SizedBox(height: 16),
                  if (attempts.length > 1) _buildHistoryChips(attempts),
                  if (attempts.length > 1) const SizedBox(height: 16),
                  _animatedSection(
                    keyLabel: 'summary-${_selectedAttempt.id}',
                    delayMs: 360,
                    child: _buildPerformanceOverview(_selectedAttempt),
                  ),
                  const SizedBox(height: 16),
                  _animatedSection(
                    keyLabel: 'review-header-${_selectedAttempt.id}',
                    delayMs: 180,
                    child: Row(
                      children: [
                        const Text(
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
                            color: AppColors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${_selectedAttempt.questions.length} soal',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _animatedSection(
                    keyLabel: 'review-${_selectedAttempt.id}',
                    delayMs: 480,
                    child: Column(
                      children: _selectedAttempt.questions
                          .map(_buildQuestionReview)
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
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

  Widget _buildHeroCard(LessonAttempt attempt) {
    final passed = attempt.passed == true;
    final statusLabel =
        attempt.statusLabel ?? (passed ? 'Lulus' : 'Belum Lulus');
    final statusMessage =
        attempt.statusMessage ??
        (passed
            ? 'Selamat! Anda berhasil menyelesaikan kuis ini dengan baik.'
            : 'Jangan menyerah! Terus belajar dan coba lagi.');
    final completedAtLabel =
        attempt.completedAtLabel ?? formatAppDateTime(attempt.submittedAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: passed
              ? [const Color(0xFF0EA5E9), const Color(0xFF22C55E)]
              : [const Color(0xFFFF8A3D), const Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (passed ? Colors.green : Colors.orange).withValues(
              alpha: 0.24,
            ),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -18,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -18,
            left: -12,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildScoreDial(attempt.percentage),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attempt.lessonTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          statusMessage,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.94),
                            fontSize: 12,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildHeroMeta(
                              Icons.label_rounded,
                              attempt.attemptLabel,
                            ),
                            _buildHeroMeta(
                              Icons.schedule_rounded,
                              completedAtLabel,
                            ),
                            _buildHeroMeta(
                              Icons.timer_rounded,
                              attempt.durationLabel ?? '-',
                            ),
                            _buildHeroMeta(
                              Icons.flag_rounded,
                              'Passing ${attempt.passingGrade ?? 0}%',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDial(double percent) {
    final clamped = (percent / 100).clamp(0.0, 1.0);

    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: CircularProgressIndicator(
              value: clamped,
              strokeWidth: 10,
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${percent.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Nilai',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMeta(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.85)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryChips(List<LessonAttempt> attempts) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2F7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attempts.length,
        separatorBuilder: (context, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final attempt = attempts[index];
          final isSelected = attempt.id == _selectedAttempt.id;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedAttempt = attempt;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : const [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    const Padding(
                      padding: EdgeInsets.only(right: 6),
                      child: Icon(Icons.check, size: 14, color: AppColors.red),
                    ),
                  Text(
                    attempt.attemptLabel,
                    style: TextStyle(
                      color: isSelected ? AppColors.red : AppColors.slate,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPerformanceOverview(LessonAttempt attempt) {
    final passingGrade = attempt.passingGrade ?? 0;
    final correctAnswers = attempt.correctAnswers ?? 0;
    final totalQuestions = attempt.totalQuestions ?? attempt.questions.length;
    final wrongAnswers =
        attempt.wrongAnswers ?? (totalQuestions - correctAnswers);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tileWidth = (constraints.maxWidth - 12) / 2;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      color: AppColors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ringkasan Hasil',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.charcoal,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Data ditarik langsung dari backend',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // _buildMetricTile(
                  //   width: tileWidth,
                  //   label: 'Nilai',
                  //   value: '${attempt.percentage.toStringAsFixed(0)}%',
                  //   accentColor: AppColors.red,
                  //   icon: Icons.auto_graph_rounded,
                  // ),
                  _buildMetricTile(
                    width: tileWidth,
                    label: 'Benar',
                    value: '$correctAnswers',
                    accentColor: Colors.green,
                    icon: Icons.check_circle_rounded,
                  ),
                  _buildMetricTile(
                    width: tileWidth,
                    label: 'Salah',
                    value: '$wrongAnswers',
                    accentColor: Colors.orange,
                    icon: Icons.cancel_rounded,
                  ),
                  _buildMetricTile(
                    width: tileWidth,
                    label: 'Total Soal',
                    value: '$totalQuestions',
                    accentColor: Colors.blue,
                    icon: Icons.quiz_rounded,
                  ),
                  _buildMetricTile(
                    width: tileWidth,
                    label: 'Passing Grade',
                    value: '$passingGrade%',
                    accentColor: Colors.purple,
                    icon: Icons.flag_rounded,
                  ),
                  // _buildMetricTile(
                  //   width: tileWidth,
                  //   label: 'Durasi',
                  //   value: attempt.durationLabel ?? '-',
                  //   accentColor: Colors.teal,
                  //   icon: Icons.timer_rounded,
                  // ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricTile({
    required double width,
    required String label,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.slate),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.charcoal,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Soal ${question.questionIndex + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.red,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${question.options.length} opsi',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.slate,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            question.questionText,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w700,
              color: AppColors.charcoal,
            ),
          ),
          const SizedBox(height: 12),
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
            final shadowColor = isCorrect
                ? Colors.green.withValues(alpha: 0.14)
                : isSelected
                ? Colors.red.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.03);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? Colors.green
                          : isSelected
                          ? Colors.red
                          : AppColors.pearl,
                      borderRadius: BorderRadius.circular(12),
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
                        height: 1.45,
                        color: AppColors.charcoal,
                      ),
                    ),
                  ),
                  if (label.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
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
