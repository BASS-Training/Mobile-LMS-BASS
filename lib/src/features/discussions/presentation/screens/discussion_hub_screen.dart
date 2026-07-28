import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/discussions/domain/entities/discussion_structure.dart';
import 'package:lms_mobile_app/src/features/discussions/presentation/cubit/discussion_structure_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Cara pengurutan daftar kelas di pemilih diskusi.
enum _CourseSort { mostDiscussions, newest, oldest }

extension on _CourseSort {
  String get label => switch (this) {
    _CourseSort.mostDiscussions => 'Terbanyak',
    _CourseSort.newest => 'Terbaru',
    _CourseSort.oldest => 'Terlama',
  };

  IconData get icon => switch (this) {
    _CourseSort.mostDiscussions => Icons.forum_rounded,
    _CourseSort.newest => Icons.schedule_rounded,
    _CourseSort.oldest => Icons.history_rounded,
  };
}

/// Diskusi = pilih kelas dulu (seperti fitur lain), lalu masuk ke forum kelas
/// itu ([DiscussionCourseForumScreen]) yang menampilkan semua diskusinya dengan
/// filter modul + urutan. Halaman ini hanya daftar kelas + jumlah diskusinya.
class DiscussionHubScreen extends StatefulWidget {
  const DiscussionHubScreen({super.key});

  @override
  State<DiscussionHubScreen> createState() => _DiscussionHubScreenState();
}

class _DiscussionHubScreenState extends State<DiscussionHubScreen> {
  final _cubit = ServiceLocator().locator<DiscussionStructureCubit>();
  _CourseSort _sort = _CourseSort.mostDiscussions;

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  int _count(DiscussionCourseGroup g) =>
      g.lessons.fold(0, (sum, l) => sum + l.discussionCount);

  /// Kunci urut waktu: pakai tanggal buat bila ada, jika belum dikirim backend
  /// gunakan courseId (auto-increment) sebagai proksi urutan pembuatan.
  int _recencyKey(DiscussionCourseGroup g) {
    final dt = DateTime.tryParse(g.createdAt ?? '');
    if (dt != null) return dt.millisecondsSinceEpoch;
    return int.tryParse(g.courseId) ?? 0;
  }

  List<DiscussionCourseGroup> _sortGroups(List<DiscussionCourseGroup> list) {
    final out = [...list];
    switch (_sort) {
      case _CourseSort.mostDiscussions:
        out.sort((a, b) {
          final byCount = _count(b).compareTo(_count(a));
          return byCount != 0
              ? byCount
              : a.courseTitle.compareTo(b.courseTitle);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandAppBar(
        title: 'Diskusi',
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: () => _cubit.load(),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      body: BlocBuilder<DiscussionStructureCubit, DiscussionStructureState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.status == DiscussionStructureStatus.loading ||
              state.status == DiscussionStructureStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            );
          }
          if (state.status == DiscussionStructureStatus.error) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat diskusi',
              message: state.error ?? 'Terjadi kesalahan.',
              actionLabel: 'Coba lagi',
              onAction: () => _cubit.load(),
            );
          }
          if (state.groups.isEmpty) {
            return const AppEmptyState(
              icon: Icons.forum_outlined,
              title: 'Belum ada kelas',
              message:
                  'Forum diskusi dari kelas yang kamu ikuti akan muncul di sini.',
            );
          }

          final groups = _sortGroups(state.groups);

          return Column(
            children: [
              _SortBar(
                current: _sort,
                onChanged: (m) => setState(() => _sort = m),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.brandPrimary,
                  onRefresh: () => _cubit.load(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Pilih kelas untuk membuka forum diskusinya',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      for (final g in groups)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CourseTile(
                            group: g,
                            discussionCount: _count(g),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Bar pemilih urutan yang menetap di atas daftar kelas.
class _SortBar extends StatelessWidget {
  final _CourseSort current;
  final ValueChanged<_CourseSort> onChanged;

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

/// Kartu kelas di pemilih — ketuk untuk membuka forum diskusi kelas itu.
class _CourseTile extends StatelessWidget {
  final DiscussionCourseGroup group;
  final int discussionCount;

  const _CourseTile({required this.group, required this.discussionCount});

  @override
  Widget build(BuildContext context) {
    final hasDiscussion = discussionCount > 0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.discussionCourse, extra: group),
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
                  color: AppColors.brandPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.forum_rounded,
                  color: AppColors.brandPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.courseTitle,
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
                    Text(
                      hasDiscussion
                          ? '$discussionCount diskusi'
                          : 'Belum ada diskusi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: hasDiscussion
                            ? AppColors.brandText
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
