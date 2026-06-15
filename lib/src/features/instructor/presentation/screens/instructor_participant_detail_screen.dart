import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/instructor/domain/entities/instructor_entities.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/instructor_overview_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';
import 'package:lms_mobile_app/src/shared/widgets/progress_ring.dart';

/// Rich per-participant progress: overall snapshot + quiz / essay / case-study
/// breakdown (mirrors the web progress report).
class InstructorParticipantDetailScreen extends StatelessWidget {
  final String courseId;
  final String userId;

  const InstructorParticipantDetailScreen({
    super.key,
    required this.courseId,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ParticipantDetailCubit>(
      create: (_) => ServiceLocator().locator<ParticipantDetailCubit>(
        param1: courseId,
        param2: userId,
      )..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const BrandAppBar(title: 'Detail Peserta'),
        body: BlocBuilder<ParticipantDetailCubit, ParticipantDetailState>(
          builder: (context, state) {
            if (state.status == InstructorStatus.loading ||
                state.status == InstructorStatus.initial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.brandPrimary),
              );
            }
            if (state.status == InstructorStatus.error || state.data == null) {
              return AppEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Gagal memuat',
                message: state.error ?? 'Terjadi kesalahan.',
                actionLabel: 'Coba lagi',
                onAction: () => context.read<ParticipantDetailCubit>().load(),
              );
            }

            final d = state.data!;
            return RefreshIndicator(
              color: AppColors.brandPrimary,
              onRefresh: () => context.read<ParticipantDetailCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                children: [
                  _profile(d),
                  const SizedBox(height: 16),
                  _overallCard(d),
                  const SizedBox(height: 22),
                  if (d.quizzes.isNotEmpty) ...[
                    _sectionTitle('Kuis', d.quizzes.length),
                    const SizedBox(height: 10),
                    ...d.quizzes.map(_quizTile),
                    const SizedBox(height: 18),
                  ],
                  if (d.essays.isNotEmpty) ...[
                    _sectionTitle('Essay', d.essays.length),
                    const SizedBox(height: 10),
                    ...d.essays.map(_submissionTile),
                    const SizedBox(height: 18),
                  ],
                  if (d.caseStudies.isNotEmpty) ...[
                    _sectionTitle('Studi Kasus', d.caseStudies.length),
                    const SizedBox(height: 10),
                    ...d.caseStudies.map(_submissionTile),
                  ],
                  if (d.quizzes.isEmpty &&
                      d.essays.isEmpty &&
                      d.caseStudies.isEmpty)
                    _infoCard('Belum ada aktivitas penilaian dari peserta ini.'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _profile(ParticipantProgressDetail d) {
    final initial = d.name.trim().isNotEmpty ? d.name.trim()[0].toUpperCase() : '?';
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.brandPrimary.withValues(alpha: 0.12),
          child: Text(
            initial,
            style: const TextStyle(
              color: AppColors.brandPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              if (d.email.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  d.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _overallCard(ParticipantProgressDetail d) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Column(
        children: [
          Row(
            children: [
              ProgressRing(
                percent: (d.progressPercentage / 100).clamp(0, 1).toDouble(),
                size: 72,
                strokeWidth: 7,
                center: Text(
                  '${d.progressPercentage.toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    _metric('Materi', '${d.completedContents}/${d.totalContents}'),
                    const _Divider(),
                    _metric('Lesson', '${d.completedLessons}/${d.totalLessons}'),
                    const _Divider(),
                    _metric(
                      'Kuis lulus',
                      '${d.completedQuizzes}/${d.totalQuizzes}',
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (d.totalQuizzes > 0) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insights_rounded,
                      size: 16, color: AppColors.info),
                  const SizedBox(width: 8),
                  Text(
                    'Rata-rata nilai kuis',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${d.averageQuizScore.toStringAsFixed(d.averageQuizScore % 1 == 0 ? 0 : 1)}%',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _quizTile(AssessmentResult q) {
    final pct = q.percentage?.toDouble() ?? 0;
    final passed = q.passed ?? false;
    return _tile(
      icon: Icons.quiz_rounded,
      iconColor: const Color(0xFFE8890C),
      title: q.title,
      subtitle: 'Nilai ${q.score ?? 0}/${q.maxScore ?? 0}',
      trailing: _pill(
        '${pct.toInt()}% · ${passed ? 'Lulus' : 'Belum'}',
        passed ? AppColors.success : AppColors.warning,
      ),
    );
  }

  Widget _submissionTile(AssessmentResult s) {
    final String label;
    final Color color;
    if (!s.graded) {
      label = 'Perlu dinilai';
      color = AppColors.warning;
    } else if (s.scoringEnabled && s.score != null) {
      label = 'Nilai ${s.score}${s.maxScore != null ? '/${s.maxScore}' : ''}';
      color = AppColors.success;
    } else {
      label = 'Sudah dinilai';
      color = AppColors.success;
    }
    final isEssay = s.maxScore != null || s.scoringEnabled;
    return _tile(
      icon: isEssay ? Icons.edit_note_rounded : Icons.assignment_rounded,
      iconColor: const Color(0xFF8B5CF6),
      title: s.title,
      subtitle: s.graded ? 'Sudah dikumpulkan' : 'Menunggu penilaian',
      trailing: _pill(label, color),
    );
  }

  Widget _tile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _card(),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _infoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _card(),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }

  BoxDecoration _card() => BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: AppColors.borderSubtle),
    boxShadow: AppShadows.xs,
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7),
      child: Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
    );
  }
}
