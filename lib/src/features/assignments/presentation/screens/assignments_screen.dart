import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/utils/lesson_route_resolver.dart';
import 'package:lms_mobile_app/src/features/assignments/domain/assignment_builder.dart';
import 'package:lms_mobile_app/src/features/assignments/domain/entities/assignment_task.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Halaman Penugasan (peserta): mengumpulkan semua tugas yang butuh dikerjakan /
/// dinilai (essay, studi kasus, dokumen) yang tersebar di konten course, dalam
/// satu tempat. Diturunkan dari data course yang sudah dimuat, jadi menghormati
/// unlock & konsisten dengan tampilan in-course.
class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  Future<void> _openTask(AssignmentTask task) async {
    if (task.isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selesaikan materi sebelumnya untuk membuka tugas ini.'),
        ),
      );
      return;
    }
    final route = LessonRouteResolver.routeForType(task.type);
    await context.push(
      route,
      extra: {
        'lesson': task.lesson,
        'course': task.course,
        'lessonIndex': task.lessonIndex,
      },
    );
    // Status tugas bisa berubah setelah dikerjakan — segarkan sumbernya.
    if (mounted) {
      context.read<CourseBloc>().add(const RefreshCoursesEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Penugasan'),
      body: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            );
          }
          if (state is CourseFailure) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat',
              message: state.message,
              actionLabel: 'Coba lagi',
              onAction: () =>
                  context.read<CourseBloc>().add(const GetCoursesEvent()),
            );
          }
          if (state is! CourseLoaded) return const SizedBox.shrink();

          final owned = state.courses.where((c) => c.isOwned).toList();
          final tasks = AssignmentBuilder.fromCourses(owned);

          if (tasks.isEmpty) {
            return const AppEmptyState(
              icon: Icons.task_alt_rounded,
              title: 'Belum ada tugas',
              message:
                  'Tugas essay, studi kasus, dan dokumen dari kursusmu akan muncul di sini.',
            );
          }

          final needsAction = tasks.where((t) => t.needsAction).toList();
          final waiting = tasks.where((t) => t.isWaiting).toList();
          final done = tasks.where((t) => t.isDone).toList();
          final locked = tasks.where((t) => t.isLocked).toList();

          return RefreshIndicator(
            color: AppColors.brandPrimary,
            onRefresh: () async =>
                context.read<CourseBloc>().add(const RefreshCoursesEvent()),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              children: [
                _summary(needsAction.length, tasks.length),
                const SizedBox(height: 14),
                ..._section('Perlu Dikerjakan', needsAction),
                ..._section('Menunggu Penilaian', waiting),
                ..._section('Selesai', done),
                ..._section('Terkunci', locked),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _summary(int needs, int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              color: AppColors.brandPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment_turned_in_rounded,
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
                  needs == 0 ? 'Semua tugas beres 🎉' : '$needs tugas perlu dikerjakan',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$total tugas total dari kursusmu',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _section(String title, List<AssignmentTask> items) {
    if (items.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(2, 8, 2, 10),
        child: Text(
          '$title · ${items.length}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      for (final task in items)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _TaskTile(task: task, onTap: () => _openTask(task)),
        ),
    ];
  }
}

class _TaskTile extends StatelessWidget {
  final AssignmentTask task;
  final VoidCallback onTap;

  const _TaskTile({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final visual = _TypeVisual.of(task.type);
    return Opacity(
      opacity: task.isLocked ? 0.6 : 1,
      child: Material(
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
                    color: visual.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    task.isLocked ? Icons.lock_outline_rounded : visual.icon,
                    color: visual.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.lesson.title,
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
                        '${visual.label} · ${task.courseTitle}',
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
                _StatusPill(status: task.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeVisual {
  final IconData icon;
  final Color color;
  final String label;

  const _TypeVisual(this.icon, this.color, this.label);

  static _TypeVisual of(String type) {
    switch (type.toLowerCase()) {
      case 'essay':
        return const _TypeVisual(
          Icons.edit_note_rounded,
          Color(0xFF8B5CF6),
          'Essay',
        );
      case 'document':
        return const _TypeVisual(
          Icons.upload_file_rounded,
          Color(0xFF2563EB),
          'Dokumen',
        );
      case 'case_study':
      default:
        return const _TypeVisual(
          Icons.assignment_rounded,
          Color(0xFFD97706),
          'Studi Kasus',
        );
    }
  }
}

class _StatusPill extends StatelessWidget {
  final AssignmentStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      AssignmentStatus.todo => ('Belum dikerjakan', AppColors.warning),
      AssignmentStatus.failed => ('Perlu revisi', const Color(0xFFDC2626)),
      AssignmentStatus.submitted => ('Menunggu nilai', AppColors.info),
      AssignmentStatus.passed => ('Lulus', AppColors.success),
      AssignmentStatus.done => ('Selesai', AppColors.success),
      AssignmentStatus.locked => ('Terkunci', AppColors.textTertiary),
    };
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
}
