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

/// Halaman Penugasan/Penilaian instruktur.
///
/// - courseId KOSONG → **pemilih kelas** (dari dashboard, ringan — TIDAK memuat
///   satu pun submission). Ketuk kelas → buka antrian kelas itu. Ini mencegah
///   memuat ribuan tugas sekaligus (yang bisa membuat app crash).
/// - courseId TERISI → antrian tugas kelas tsb saja (dimuat saat dibuka),
///   dengan urutan Terbaru/Terlama.
class InstructorGradingQueueScreen extends StatelessWidget {
  final String courseId;
  final String courseTitle;

  const InstructorGradingQueueScreen({
    super.key,
    required this.courseId,
    this.courseTitle = '',
  });

  @override
  Widget build(BuildContext context) {
    if (courseId.isEmpty) return const _GradingCoursePicker();
    return _CourseGradingQueue(courseId: courseId, courseTitle: courseTitle);
  }
}

/// Cara pengurutan daftar kelas di pemilih penilaian.
enum _CourseSort { pending, newest, oldest }

extension on _CourseSort {
  String get label => switch (this) {
    _CourseSort.pending => 'Perlu Nilai',
    _CourseSort.newest => 'Terbaru',
    _CourseSort.oldest => 'Terlama',
  };

  IconData get icon => switch (this) {
    _CourseSort.pending => Icons.rate_review_rounded,
    _CourseSort.newest => Icons.schedule_rounded,
    _CourseSort.oldest => Icons.history_rounded,
  };
}

/// Pemilih kelas untuk penilaian — daftar kelas + jumlah tugas menunggu, tanpa
/// memuat submission apa pun. Sumber data: dashboard instruktur (hitung agregat).
class _GradingCoursePicker extends StatefulWidget {
  const _GradingCoursePicker();

  @override
  State<_GradingCoursePicker> createState() => _GradingCoursePickerState();
}

class _GradingCoursePickerState extends State<_GradingCoursePicker> {
  _CourseSort _sort = _CourseSort.pending;

  /// Kunci urut waktu: pakai tanggal buat bila ada, jika belum dikirim backend
  /// gunakan id (auto-increment) sebagai proksi urutan pembuatan.
  int _recencyKey(InstructorCourseSummary c) {
    final dt = DateTime.tryParse(c.createdAt ?? '');
    if (dt != null) return dt.millisecondsSinceEpoch;
    return int.tryParse(c.id) ?? 0;
  }

  List<InstructorCourseSummary> _sortCourses(
    List<InstructorCourseSummary> list,
  ) {
    final out = [...list];
    switch (_sort) {
      case _CourseSort.pending:
        // Kelas dengan tugas menunggu didahulukan, lalu berdasarkan judul.
        out.sort((a, b) {
          final byPending = b.pendingCount.compareTo(a.pendingCount);
          return byPending != 0 ? byPending : a.title.compareTo(b.title);
        });
      case _CourseSort.newest:
        out.sort((a, b) => _recencyKey(b).compareTo(_recencyKey(a)));
      case _CourseSort.oldest:
        out.sort((a, b) => _recencyKey(a).compareTo(_recencyKey(b)));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InstructorDashboardCubit>(
      create: (_) =>
          ServiceLocator().locator<InstructorDashboardCubit>()..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const BrandAppBar(title: 'Penugasan'),
        body: BlocBuilder<InstructorDashboardCubit, InstructorDashboardState>(
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
                onAction: () => context.read<InstructorDashboardCubit>().load(),
              );
            }
            final data = state.data;
            final courses = data?.courses ?? const <InstructorCourseSummary>[];

            if (courses.isEmpty) {
              return const AppEmptyState(
                icon: Icons.folder_open_rounded,
                title: 'Belum ada kelas',
                message: 'Kelas yang Anda kelola akan muncul di sini.',
              );
            }

            final sorted = _sortCourses(courses);
            final pendingTotal = data?.pendingGrading ?? 0;
            return Column(
              children: [
                _CourseSortBar(
                  current: _sort,
                  onChanged: (m) => setState(() => _sort = m),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.brandPrimary,
                    onRefresh: () =>
                        context.read<InstructorDashboardCubit>().load(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            pendingTotal == 0
                                ? 'Semua tugas sudah dinilai 🎉'
                                : '$pendingTotal tugas menunggu · ${courses.length} kelas',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        for (final c in sorted)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _CoursePickTile(summary: c),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Bar pemilih urutan untuk daftar kelas.
class _CourseSortBar extends StatelessWidget {
  final _CourseSort current;
  final ValueChanged<_CourseSort> onChanged;

  const _CourseSortBar({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Icon(Icons.sort_rounded, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final mode in _CourseSort.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _SortChip(
                        label: mode.label,
                        icon: mode.icon,
                        selected: mode == current,
                        onTap: () => onChanged(mode),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu kelas di pemilih — ketuk untuk membuka antrian penilaian kelas itu.
class _CoursePickTile extends StatelessWidget {
  final InstructorCourseSummary summary;

  const _CoursePickTile({required this.summary});

  @override
  Widget build(BuildContext context) {
    final pending = summary.pendingCount;
    final hasPending = pending > 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(
          AppRoutes.instructorGradingQueue,
          extra: {'courseId': summary.id, 'courseTitle': summary.title},
        ),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (hasPending ? AppColors.warning : AppColors.success)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  hasPending
                      ? Icons.rate_review_rounded
                      : Icons.check_circle_rounded,
                  color: hasPending ? AppColors.warning : AppColors.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.groups_rounded,
                          size: 14,
                          color: AppColors.info,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${summary.participantCount} peserta',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CountPill(pending: pending),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final int pending;
  const _CountPill({required this.pending});

  @override
  Widget build(BuildContext context) {
    final hasPending = pending > 0;
    final color = hasPending ? AppColors.warning : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        hasPending ? '$pending perlu nilai' : 'Tuntas',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

/// Cara pengurutan antrian satu kelas.
enum _SortMode { newest, oldest }

extension on _SortMode {
  String get label => this == _SortMode.newest ? 'Terbaru' : 'Terlama';
  IconData get icon =>
      this == _SortMode.newest ? Icons.schedule_rounded : Icons.history_rounded;
}

/// Antrian tugas untuk SATU kelas — memuat hanya submission kelas ini, jadi
/// jumlahnya terbatas & aman ditampilkan.
class _CourseGradingQueue extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const _CourseGradingQueue({required this.courseId, required this.courseTitle});

  @override
  State<_CourseGradingQueue> createState() => _CourseGradingQueueState();
}

class _CourseGradingQueueState extends State<_CourseGradingQueue> {
  _SortMode _sort = _SortMode.newest;

  DateTime _submittedAt(GradingQueueItem i) =>
      DateTime.tryParse(i.submittedAt ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);

  List<GradingQueueItem> _sorted(List<GradingQueueItem> items) {
    final list = [...items];
    final newest = _sort == _SortMode.newest;
    list.sort((a, b) {
      final da = _submittedAt(a);
      final db = _submittedAt(b);
      return newest ? db.compareTo(da) : da.compareTo(db);
    });
    return list;
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GradingQueueCubit>(
      create: (_) =>
          ServiceLocator().locator<GradingQueueCubit>(param1: widget.courseId)
            ..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: BrandAppBar(
          title: widget.courseTitle.isEmpty ? 'Penilaian' : widget.courseTitle,
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
            final sorted = _sorted(state.items);
            return Column(
              children: [
                _SortBar(
                  current: _sort,
                  onChanged: (m) => setState(() => _sort = m),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.brandPrimary,
                    onRefresh: () => context.read<GradingQueueCubit>().load(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: sorted.length + 1,
                      separatorBuilder: (_, i) =>
                          SizedBox(height: i == 0 ? 0 : 10),
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              '${state.items.length} tugas perlu dinilai',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        final item = sorted[i - 1];
                        return _QueueTile(
                          item: item,
                          onTap: () => _openGrading(context, item),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Bar pemilih urutan yang menetap di atas daftar.
class _SortBar extends StatelessWidget {
  final _SortMode current;
  final ValueChanged<_SortMode> onChanged;

  const _SortBar({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        children: [
          Icon(Icons.sort_rounded, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          for (final mode in _SortMode.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _SortChip(
                label: mode.label,
                icon: mode.icon,
                selected: mode == current,
                onTap: () => onChanged(mode),
              ),
            ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.brandPrimary : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
