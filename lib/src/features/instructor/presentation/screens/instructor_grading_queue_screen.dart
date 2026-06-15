import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/instructor/domain/entities/instructor_entities.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/instructor_overview_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Instructor/admin view: the queue of essay & case-study submissions to grade.
class InstructorGradingQueueScreen extends StatelessWidget {
  final String courseId;

  const InstructorGradingQueueScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GradingQueueCubit>(
      create: (_) =>
          ServiceLocator().locator<GradingQueueCubit>(param1: courseId)..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const BrandAppBar(title: 'Penilaian'),
        body: BlocBuilder<GradingQueueCubit, GradingQueueState>(
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
                onAction: () => context.read<GradingQueueCubit>().load(),
              );
            }
            if (state.items.isEmpty) {
              return const AppEmptyState(
                icon: Icons.task_alt_rounded,
                title: 'Belum ada yang perlu dinilai',
                message:
                    'Submission essay & studi kasus dari peserta akan muncul di sini.',
              );
            }
            return RefreshIndicator(
              color: AppColors.brandPrimary,
              onRefresh: () => context.read<GradingQueueCubit>().load(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.items.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${state.pendingCount} menunggu dinilai · ${state.items.length} total',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  final item = state.items[i - 1];
                  return _QueueTile(
                    item: item,
                    onTap: () => _openGrading(context, item),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openGrading(BuildContext context, GradingQueueItem item) async {
    final cubit = context.read<GradingQueueCubit>();
    await context.push(
      item.isEssay
          ? AppRoutes.instructorEssayGrading
          : AppRoutes.instructorCaseStudyGrading,
      extra: item.submissionId,
    );
    // Kembali dari layar penilaian → segarkan status antrian.
    await cubit.load();
  }
}

class _QueueTile extends StatelessWidget {
  final GradingQueueItem item;
  final VoidCallback onTap;

  const _QueueTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final typeColor = item.isEssay
        ? const Color(0xFF8B5CF6)
        : const Color(0xFFD97706);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.xs,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.isEssay
                      ? Icons.edit_note_rounded
                      : Icons.assignment_rounded,
                  color: typeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.participantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.contentTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(pending: item.isPending),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool pending;
  const _StatusPill({required this.pending});

  @override
  Widget build(BuildContext context) {
    final color = pending ? AppColors.warning : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        pending ? 'Perlu nilai' : 'Selesai',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
