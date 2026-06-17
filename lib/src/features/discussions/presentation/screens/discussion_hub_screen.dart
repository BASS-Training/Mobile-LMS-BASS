import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/discussions/domain/entities/discussion_structure.dart';
import 'package:lms_mobile_app/src/features/discussions/presentation/cubit/discussion_structure_cubit.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/discussion/discussion_cubit.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/discussion/discussion_panel.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Discussion hub: pick a course (dropdown) and a lesson (chip strip) at the
/// top; the selected lesson's discussion thread fills the rest of the screen.
/// Mirrors the course→lesson structure so browsing feels contextual.
class DiscussionHubScreen extends StatefulWidget {
  const DiscussionHubScreen({super.key});

  @override
  State<DiscussionHubScreen> createState() => _DiscussionHubScreenState();
}

class _DiscussionHubScreenState extends State<DiscussionHubScreen> {
  final _cubit = ServiceLocator().locator<DiscussionStructureCubit>();

  // Current selection (null = fall back to the first available).
  String? _courseId;
  String? _contentId;

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  DiscussionCourseGroup? _course(List<DiscussionCourseGroup> groups) {
    if (groups.isEmpty) return null;
    return groups.firstWhere(
      (g) => g.courseId == _courseId,
      orElse: () => groups.first,
    );
  }

  DiscussionLessonRef? _lesson(DiscussionCourseGroup course) {
    if (course.lessons.isEmpty) return null;
    return course.lessons.firstWhere(
      (l) => l.contentId == _contentId,
      orElse: () => course.lessons.first,
    );
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

          final course = _course(state.groups);
          if (course == null) {
            return const AppEmptyState(
              icon: Icons.forum_outlined,
              title: 'Belum ada kelas',
              message:
                  'Diskusi dari kelas yang kamu ikuti akan muncul di sini setelah ada materinya.',
            );
          }
          final lesson = _lesson(course);

          return Column(
            children: [
              _Selector(
                groups: state.groups,
                course: course,
                lesson: lesson,
                onCourseChanged: (id) => setState(() {
                  _courseId = id;
                  _contentId = null; // reset to first lesson of the new course
                }),
                onLessonChanged: (id) => setState(() => _contentId = id),
              ),
              Divider(height: 1, color: AppColors.borderSubtle),
              Expanded(
                child: lesson == null
                    ? const AppEmptyState(
                        icon: Icons.menu_book_outlined,
                        title: 'Kelas ini belum punya materi',
                        message: 'Belum ada materi untuk didiskusikan.',
                      )
                    : BlocProvider<DiscussionCubit>(
                        key: ValueKey(lesson.contentId),
                        create: (_) => ServiceLocator()
                            .locator<DiscussionCubit>(param1: lesson.contentId)
                          ..load(),
                        child: const DiscussionPanel(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The course dropdown + horizontal lesson chip strip.
class _Selector extends StatelessWidget {
  final List<DiscussionCourseGroup> groups;
  final DiscussionCourseGroup course;
  final DiscussionLessonRef? lesson;
  final ValueChanged<String> onCourseChanged;
  final ValueChanged<String> onLessonChanged;

  const _Selector({
    required this.groups,
    required this.course,
    required this.lesson,
    required this.onCourseChanged,
    required this.onLessonChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.only(top: 12, bottom: 10),
      child: Column(
        children: [
          // Course dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: course.courseId,
                  borderRadius: BorderRadius.circular(12),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  items: [
                    for (final g in groups)
                      DropdownMenuItem(
                        value: g.courseId,
                        child: Text(
                          g.courseTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (v) {
                    if (v != null && v != course.courseId) onCourseChanged(v);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Lesson chips
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: course.lessons.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final l = course.lessons[i];
                return _LessonChip(
                  lesson: l,
                  active: l.contentId == lesson?.contentId,
                  onTap: () => onLessonChanged(l.contentId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonChip extends StatelessWidget {
  final DiscussionLessonRef lesson;
  final bool active;
  final VoidCallback onTap;

  const _LessonChip({
    required this.lesson,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : AppColors.textSecondary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.brandPrimary : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active ? AppColors.brandPrimary : AppColors.borderDefault,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  lesson.lessonTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
              ),
              if (lesson.discussionCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: active
                        ? Colors.white.withValues(alpha: 0.25)
                        : AppColors.brandPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${lesson.discussionCount}',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: active ? Colors.white : AppColors.brandPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
