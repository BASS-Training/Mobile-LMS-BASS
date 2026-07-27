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
        appBar: BrandAppBar(
          title: courseId.isEmpty ? 'Inbox Penilaian' : 'Penilaian',
        ),
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
                    'Submission essay, studi kasus & dokumen dari peserta akan muncul di sini.',
              );
            }
            final groups = _groupByCourse(state.items);
            return RefreshIndicator(
              color: AppColors.brandPrimary,
              onRefresh: () => context.read<GradingQueueCubit>().load(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '${state.items.length} perlu dinilai · ${groups.length} kelas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  for (var g = 0; g < groups.length; g++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CourseGroup(
                        title: groups[g].title,
                        items: groups[g].items,
                        initiallyExpanded: groups.length == 1 || g == 0,
                        onOpen: (item) => _openGrading(context, item),
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

  Future<void> _openGrading(BuildContext context, GradingQueueItem item) async {
    final cubit = context.read<GradingQueueCubit>();
    if (item.isDocument) {
      await context.push(
        AppRoutes.instructorDocumentGrading,
        extra: {
          'submissionId': item.submissionId,
          'contentId': item.contentId,
          'contentTitle': item.contentTitle,
          'participantName': item.participantName,
        },
      );
    } else {
      await context.push(
        item.isEssay
            ? AppRoutes.instructorEssayGrading
            : AppRoutes.instructorCaseStudyGrading,
        extra: item.submissionId,
      );
    }
    // Kembali dari layar penilaian → segarkan status antrian.
    await cubit.load();
  }

  /// Kelompokkan item per kelas, mempertahankan urutan kemunculan (server sudah
  /// mengirim terbaru dulu), agar tidak berjejer panjang & mudah dipindai.
  List<({String title, List<GradingQueueItem> items})> _groupByCourse(
    List<GradingQueueItem> items,
  ) {
    final order = <String>[];
    final map = <String, List<GradingQueueItem>>{};
    for (final item in items) {
      final key = item.courseTitle.isEmpty ? 'Lainnya' : item.courseTitle;
      if (!map.containsKey(key)) {
        map[key] = <GradingQueueItem>[];
        order.add(key);
      }
      map[key]!.add(item);
    }
    return [for (final key in order) (title: key, items: map[key]!)];
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
        : (item.isDocument
              ? const Color(0xFF2563EB)
              : const Color(0xFFD97706));
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
                      : (item.isDocument
                            ? Icons.upload_file_rounded
                            : Icons.assignment_rounded),
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
                      style: TextStyle(
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
                      style: TextStyle(
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

/// Satu kelas sebagai grup yang bisa dilipat — menjaga daftar penilaian ringkas
/// alih-alih ratusan tile berjejer panjang.
class _CourseGroup extends StatefulWidget {
  final String title;
  final List<GradingQueueItem> items;
  final bool initiallyExpanded;
  final void Function(GradingQueueItem item) onOpen;

  const _CourseGroup({
    required this.title,
    required this.items,
    required this.initiallyExpanded,
    required this.onOpen,
  });

  @override
  State<_CourseGroup> createState() => _CourseGroupState();
}

class _CourseGroupState extends State<_CourseGroup> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_rounded,
                    size: 20,
                    color: AppColors.brandText,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${widget.items.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded)
          for (final item in widget.items)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _QueueTile(item: item, onTap: () => widget.onOpen(item)),
            ),
      ],
    );
  }
}
