import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/entities/lesson_attempt_entity.dart';
import 'package:lms_mobile_app/src/features/lessons/domain/repositories/lesson_result_repository.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/utils/app_date_formatter.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

class ResultsListScreen extends StatelessWidget {
  final CourseEntity course;

  const ResultsListScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: AppBar(
        title: const Text('Nilai & Hasil'),
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
          future: GetIt.instance<LessonResultRepository>().getAttemptsByCourse(
            course.id,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final attempts = snapshot.data ?? const <LessonAttempt>[];
            if (attempts.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: attempts.length + 1,
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeaderCard(attempts.length);
                }

                final attempt = attempts[index - 1];
                return _buildAttemptCard(context, attempt);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCard(int attemptCount) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.red, AppColors.tomato],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.red.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.assessment_outlined, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$attemptCount pengumpulan tercatat',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptCard(BuildContext context, LessonAttempt attempt) {
    final isQuiz = attempt.lessonType == 'quiz';
    final isCaseStudy = attempt.lessonType == 'case_study';
    final statusColor = isQuiz
        ? (attempt.passed == true ? Colors.green : Colors.orange)
        : (attempt.graded ? Colors.green : AppColors.red);
    final statusText = isQuiz
        ? (attempt.passed == true ? 'Lulus' : 'Tidak Lulus')
        : (attempt.graded ? 'Sudah Dinilai' : 'Sudah Dikumpulkan');

    return PressScale(
      child: InkWell(
        onTap: () {
          if (isQuiz) {
            context.push(AppRoutes.quizResultDetail, extra: attempt);
          } else if (isCaseStudy) {
            context.push(AppRoutes.caseStudyResultDetail, extra: attempt);
          } else {
            context.push(AppRoutes.essayResultDetail, extra: attempt);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isQuiz
                      ? Icons.quiz_outlined
                      : isCaseStudy
                      ? Icons.assignment_rounded
                      : Icons.edit_note_rounded,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      attempt.lessonTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${attempt.attemptLabel} • ${formatAppDateTime(attempt.submittedAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatusChip(statusText, statusColor),
                        if (isQuiz && attempt.maxScore != null)
                          _buildStatusChip(
                            '${attempt.percentage.toStringAsFixed(0)}%',
                            AppColors.red,
                          ),
                        if (!isQuiz)
                          _buildStatusChip(
                            attempt.graded ? 'Dinilai' : 'Menunggu Nilai',
                            attempt.graded ? Colors.green : AppColors.red,
                          ),
                        if (isCaseStudy &&
                            attempt.graded &&
                            attempt.score != null &&
                            attempt.maxScore != null)
                          _buildStatusChip(
                            '${attempt.percentage.toStringAsFixed(0)}%',
                            AppColors.red,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isQuiz
                          ? '${attempt.score?.toStringAsFixed(0) ?? '0'}/${attempt.maxScore?.toStringAsFixed(0) ?? '0'} benar'
                          : isCaseStudy
                          ? (attempt.graded
                                ? (attempt.score != null
                                      ? 'Nilai: ${attempt.score!.toStringAsFixed(0)}${attempt.maxScore != null ? '/${attempt.maxScore!.toStringAsFixed(0)}' : ''}'
                                      : 'Sudah dinilai instruktur')
                                : 'Menunggu penilaian instruktur')
                          : '${attempt.questions.length} jawaban terkumpul',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.slate),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.assessment_outlined,
                size: 42,
                color: AppColors.red,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum ada nilai dan hasil',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.charcoal,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Setelah quiz atau essay dikumpulkan, riwayat nilai akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: AppColors.slate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
