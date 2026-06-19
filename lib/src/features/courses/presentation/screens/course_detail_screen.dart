import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_detail_header.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_info_cards.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_locked_access.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_section_accordion.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_section_header.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/widgets/progress_indicator.dart';
import '../../domain/entities/course_entity.dart';
import '../bloc/course/course_bloc.dart';
import '../bloc/course/course_event.dart';
import '../bloc/course/course_state.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseEntity course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  /// Melacak apakah sedang ada proses refresh agar bisa
  /// menampilkan LinearProgressIndicator di bagian atas.
  bool _isRefreshing = false;

  /// Digunakan oleh RefreshIndicator agar tahu kapan refresh selesai.
  Completer<void>? _refreshCompleter;

  @override
  void initState() {
    super.initState();
    LocalStorage.recordRecentCourse(widget.course.id);

    // Fetch data segar langsung saat screen pertama kali dibuat.
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerRefresh());
  }

  @override
  void dispose() {
    _refreshCompleter
        ?.complete(); // pastikan tidak ada completer yang tergantung
    super.dispose();
  }

  /// Dispatch refresh event dan tandai sedang loading.
  void _triggerRefresh() {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    context.read<CourseBloc>().add(const RefreshCoursesEvent());
  }

  /// Callback untuk RefreshIndicator (pull-to-refresh).
  /// Mengembalikan Future yang selesai saat BLoC emit CourseLoaded/Failure.
  Future<void> _onPullRefresh() {
    _refreshCompleter?.complete();
    _refreshCompleter = Completer<void>();
    _triggerRefresh();
    return _refreshCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        // Selesaikan paksa jika timeout, agar RefreshIndicator tidak tergantung.
      },
    );
  }

  /// Dipanggil oleh BlocConsumer listener saat BLoC selesai memproses refresh.
  void _onRefreshComplete() {
    if (!mounted) return;
    setState(() => _isRefreshing = false);
    _refreshCompleter?.complete();
    _refreshCompleter = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CourseBloc, CourseState>(
      // Hanya update UI saat state berubah secara signifikan
      buildWhen: (prev, curr) =>
          curr is CourseLoaded ||
          curr is CourseLoading ||
          curr is CourseFailure,
      listenWhen: (prev, curr) => curr is CourseLoaded || curr is CourseFailure,
      listener: (context, state) {
        // Refresh selesai — sembunyikan loading indicator.
        _onRefreshComplete();
      },
      builder: (context, state) {
        // Gunakan data terbaru dari BLoC; fallback ke widget.course
        // jika BLoC belum punya data atau course tidak ditemukan.
        CourseEntity currentCourse = widget.course;
        if (state is CourseLoaded) {
          currentCourse = state.courses.firstWhere(
            (c) => c.id == widget.course.id,
            orElse: () => widget.course,
          );
        }

        // Instructor/admin see a management view (open any lesson, grade &
        // view participant progress) instead of the participant's own progress.
        final authState = context.watch<AuthBloc>().state;
        final canManage =
            authState is AuthSuccess &&
            (authState.user.hasRole('instructor') ||
                authState.user.hasRole('admin') ||
                authState.user.hasRole('super-admin'));

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              // ── Indikator loading tipis di bagian paling atas ────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: _isRefreshing ? 3.0 : 0.0,
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.brandPrimary.withValues(
                    alpha: 0.1,
                  ),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.brandPrimary,
                  ),
                  minHeight: 3,
                ),
              ),

              // ── Konten utama dengan pull-to-refresh ──────────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onPullRefresh,
                  color: AppColors.brandPrimary,
                  backgroundColor: Colors.white,
                  strokeWidth: 2.5,
                  child: SingleChildScrollView(
                    // physics wajib agar RefreshIndicator bisa trigger
                    // meski konten pendek
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CourseDetailHeader(course: currentCourse),

                        Padding(
                          padding: const EdgeInsets.all(
                            AppMeasures.paddingLarge,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CourseInfoCards(course: currentCourse),
                              const SizedBox(height: 24),

                              Text(
                                'Tentang Kursus',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentCourse.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 24),

                              if (currentCourse.isOwned) ...[
                                if (canManage) ...[
                                  _InstructorPanel(course: currentCourse),
                                  const SizedBox(height: 24),
                                  const CourseSectionHeader(
                                    title: 'Materi Kursus',
                                  ),
                                  const SizedBox(height: 12),
                                  ...currentCourse.sections.map((section) {
                                    return CourseSectionAccordion(
                                      section: section,
                                      course: currentCourse,
                                      unlockAll: true,
                                    );
                                  }),
                                  const SizedBox(height: 24),
                                ] else ...[
                                  CourseProgressIndicator(
                                    progress: currentCourse.progressPercentage,
                                    label: 'Progres Kamu',
                                    showPercentage: true,
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 54,
                                    child: ElevatedButton.icon(
                                      onPressed: () => context.push(
                                        AppRoutes.courseResults,
                                        extra: currentCourse,
                                      ),
                                      icon: const Icon(Icons.assessment_rounded),
                                      label: const Text('Nilai & Hasil'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.brandPrimary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  CourseSectionHeader(
                                    title: 'Materi Kursus',
                                    trailing:
                                        '${currentCourse.completedLessons}/${currentCourse.totalLessons}',
                                  ),
                                  const SizedBox(height: 12),
                                  ...currentCourse.sections.map((section) {
                                    return CourseSectionAccordion(
                                      section: section,
                                      course: currentCourse,
                                    );
                                  }),
                                  const SizedBox(height: 24),
                                ],
                              ] else ...[
                                CourseLockedAccess(course: currentCourse),
                                const SizedBox(height: 24),
                                if (currentCourse.sections.isNotEmpty) ...[
                                  const CourseSectionHeader(
                                    title: 'Yang akan kamu pelajari',
                                  ),
                                  const SizedBox(height: 12),
                                  ...currentCourse.sections.map(
                                    (section) =>
                                        CourseSyllabusTile(section: section),
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Management actions shown on the course detail for instructors/admins:
/// view participant progress and grade essay / case-study submissions.
class _InstructorPanel extends StatelessWidget {
  final CourseEntity course;

  const _InstructorPanel({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.brandSurfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                size: 18,
                color: AppColors.brandText,
              ),
              SizedBox(width: 8),
              Text(
                'Mode Instruktur',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Pantau progres peserta dan nilai essay & studi kasus. Semua materi bisa kamu buka.',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.groups_rounded,
                  label: 'Progres Peserta',
                  onTap: () => context.push(
                    AppRoutes.instructorParticipants,
                    extra: {'courseId': course.id, 'courseTitle': course.title},
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.rate_review_rounded,
                  label: 'Penilaian',
                  filled: true,
                  onTap: () => context.push(
                    AppRoutes.instructorGradingQueue,
                    extra: {'courseId': course.id},
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final fg = filled ? Colors.white : AppColors.brandPrimary;
    return Material(
      color: filled ? AppColors.brandPrimary : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: filled
                ? null
                : Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
