import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:lms_mobile_app/src/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:lms_mobile_app/src/features/courses/domain/entities/course_entity.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_accent.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/widgets/course_card.dart';
import 'package:lms_mobile_app/src/features/instructor/domain/entities/instructor_entities.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/instructor_overview_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(const GetCoursesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final canManage =
            authState is AuthSuccess &&
            (authState.user.hasRole('instructor') ||
                authState.user.hasRole('admin') ||
                authState.user.hasRole('super-admin'));

        final scaffold = Scaffold(
          backgroundColor: Colors.transparent,
          appBar: BrandAppBar(
            title: canManage ? 'Kelas Saya' : 'Semua Kursus',
          ),
          body: Stack(
            children: [
              const _CourseListBackdrop(),
              Column(
                children: [
                  if (canManage)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(
                        AppMeasures.paddingLarge,
                        AppMeasures.paddingLarge,
                        AppMeasures.paddingLarge,
                        0,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.brandSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.brandPrimary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.workspace_premium_rounded,
                            color: AppColors.brandText,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Kelas yang Anda ampu. Ketuk untuk melihat materi & menilai peserta.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(AppMeasures.paddingLarge),
                    child: _buildSearchField(),
                  ),
                  Expanded(
                    child: canManage ? _buildManageList() : _buildParticipantGrid(),
                  ),
                ],
              ),
            ],
          ),
        );

        // Instructors/admins also load the aggregate dashboard so each class
        // card can show participant + pending-grading counts.
        if (canManage) {
          return BlocProvider<InstructorDashboardCubit>(
            create: (_) =>
                ServiceLocator().locator<InstructorDashboardCubit>()..load(),
            child: scaffold,
          );
        }
        return scaffold;
      },
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, _) {
          return TextField(
            controller: _searchController,
            onChanged: (value) {
              context.read<CourseBloc>().add(SearchCoursesEvent(query: value));
            },
            decoration: InputDecoration(
              hintText: AppStrings.searchCourses,
              hintStyle: TextStyle(color: AppColors.textTertiary),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.brandText,
              ),
              suffixIcon: value.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        context.read<CourseBloc>().add(
                          const SearchCoursesEvent(query: ''),
                        );
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textTertiary,
                      ),
                    )
                  : null,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Participant view ──────────────────────────────────────────────────────
  Widget _buildParticipantGrid() {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        if (state is CourseLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.brandPrimary),
          );
        }

        if (state is CourseLoaded) {
          final courses = state.courses;
          if (courses.isEmpty) {
            return _centeredMessage(
              illustration: 'assets/illustrations/empty_search.svg',
              icon: Icons.search_off_rounded,
              title: 'Kursus tidak ditemukan',
              message: 'Coba kata kunci lain atau kosongkan pencarian.',
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppMeasures.paddingLarge,
              4,
              AppMeasures.paddingLarge,
              AppMeasures.paddingLarge,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final courseEntity = courses[index];
              return CourseCard(
                course: courseEntity,
                isSaved: courseEntity.isSaved,
                onTap: () {
                  context.push(AppRoutes.courseDetail, extra: courseEntity);
                },
                onSavePressed: () {
                  final willSave = !courseEntity.isSaved;
                  context.read<CourseBloc>().add(
                    ToggleSaveCourseEvent(courseId: courseEntity.id),
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          willSave
                              ? 'Kursus disimpan ke koleksi'
                              : 'Kursus dihapus dari koleksi',
                        ),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                },
              );
            },
          );
        }

        if (state is CourseFailure) {
          return _centeredMessage(
            icon: Icons.error_outline_rounded,
            title: state.message,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ── Instructor / admin view ───────────────────────────────────────────────
  Widget _buildManageList() {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        if (state is CourseLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.brandPrimary),
          );
        }

        if (state is CourseLoaded) {
          final courses = state.courses;
          if (courses.isEmpty) {
            return _centeredMessage(
              icon: Icons.menu_book_rounded,
              title: 'Belum ada kelas',
              message: 'Kelas yang Anda ampu akan muncul di sini.',
            );
          }

          // Merge per-course teaching stats (participants / pending) by id.
          final dashState = context.watch<InstructorDashboardCubit>().state;
          final summaries = <String, InstructorCourseSummary>{
            for (final c in dashState.data?.courses ?? const []) c.id: c,
          };

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppMeasures.paddingLarge,
              4,
              AppMeasures.paddingLarge,
              AppMeasures.paddingLarge,
            ),
            itemCount: courses.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final course = courses[index];
              return _ManageCourseTile(
                course: course,
                summary: summaries[course.id],
              );
            },
          );
        }

        if (state is CourseFailure) {
          return _centeredMessage(
            icon: Icons.error_outline_rounded,
            title: state.message,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _centeredMessage({
    required IconData icon,
    required String title,
    String? message,
    String? illustration,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (illustration != null)
            SvgPicture.asset(
              illustration,
              height: 152,
              fit: BoxFit.contain,
              semanticsLabel: title,
            )
          else
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandPrimary.withValues(alpha: 0.1),
              ),
              child: Icon(icon, size: 44, color: AppColors.brandText),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Manage-style course row for instructors: title + teaching stats, opening the
/// course detail (instructor mode) where all materials are accessible.
class _ManageCourseTile extends StatelessWidget {
  final CourseEntity course;
  final InstructorCourseSummary? summary;

  const _ManageCourseTile({required this.course, this.summary});

  @override
  Widget build(BuildContext context) {
    final accent = CourseAccent.of(course.id);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(AppRoutes.courseDetail, extra: course),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: AppShadows.xs,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: accent.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    course.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      children: [
                        _miniStat(
                          Icons.menu_book_rounded,
                          '${course.totalLessons} lesson',
                          AppColors.textTertiary,
                        ),
                        if (summary != null)
                          _miniStat(
                            Icons.groups_rounded,
                            '${summary!.participantCount} peserta',
                            AppColors.info,
                          ),
                        if (summary != null && summary!.pendingCount > 0)
                          _miniStat(
                            Icons.rate_review_rounded,
                            '${summary!.pendingCount} perlu nilai',
                            AppColors.warning,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CourseListBackdrop extends StatelessWidget {
  const _CourseListBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: ColoredBox(color: AppColors.background));
  }
}
