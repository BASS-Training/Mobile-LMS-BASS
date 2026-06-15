import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/instructor/domain/entities/instructor_entities.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/instructor_overview_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Instructor/admin view: enrolled participants with a concise progress snapshot.
class InstructorParticipantsScreen extends StatelessWidget {
  final String courseId;
  final String courseTitle;

  const InstructorParticipantsScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ParticipantsCubit>(
      create: (_) =>
          ServiceLocator().locator<ParticipantsCubit>(param1: courseId)..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const BrandAppBar(title: 'Progres Peserta'),
        body: BlocBuilder<ParticipantsCubit, ParticipantsState>(
          builder: (context, state) {
            if (state.status == InstructorStatus.loading ||
                state.status == InstructorStatus.initial) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.brandPrimary),
              );
            }
            if (state.status == InstructorStatus.error) {
              return AppEmptyState(
                icon: Icons.error_outline_rounded,
                title: 'Gagal memuat',
                message: state.error ?? 'Terjadi kesalahan.',
                actionLabel: 'Coba lagi',
                onAction: () => context.read<ParticipantsCubit>().load(),
              );
            }
            if (state.items.isEmpty) {
              return const AppEmptyState(
                icon: Icons.groups_rounded,
                title: 'Belum ada peserta',
                message: 'Belum ada peserta yang terdaftar di course ini.',
              );
            }
            return RefreshIndicator(
              color: AppColors.brandPrimary,
              onRefresh: () => context.read<ParticipantsCubit>().load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) =>
                    _ParticipantTile(participant: state.items[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final ParticipantProgress participant;

  const _ParticipantTile({required this.participant});

  @override
  Widget build(BuildContext context) {
    final pct = (participant.progressPercentage).clamp(0, 100).toDouble();
    final initial = participant.name.trim().isNotEmpty
        ? participant.name.trim()[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.xs,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.brandPrimary.withValues(alpha: 0.12),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participant.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (participant.email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        participant.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (participant.pendingGrading > 0) _PendingBadge(participant.pendingGrading),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 7,
                    backgroundColor: AppColors.surfaceMuted,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.brandPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${pct.toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${participant.completedContents}/${participant.totalContents} materi selesai',
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingBadge extends StatelessWidget {
  final int count;
  const _PendingBadge(this.count);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count perlu nilai',
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: AppColors.warning,
        ),
      ),
    );
  }
}
