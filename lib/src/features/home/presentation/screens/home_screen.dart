import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_strings.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/src/features/home/domain/entities/home_stats.entity.dart';
import 'package:lms_mobile_app/src/features/home/presentation/bloc/home_bloc.dart';
import 'package:lms_mobile_app/src/features/home/presentation/bloc/home_state.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_extra_sections.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_header.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_recommended_courses.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_statistics_grid.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onShowCourses;
  final String accountRole;

  const HomeScreen({
    super.key,
    this.onShowCourses,
    this.accountRole = 'participant',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _joinClassTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(const GetCoursesEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _joinClassTokenController.dispose();
    super.dispose();
  }

  void _goToCourseList() {
    if (!mounted) return;

    if (widget.onShowCourses != null) {
      widget.onShowCourses!.call();
      return;
    }

    context.push(AppRoutes.courses);
  }

  void _handleHomeBlocListener(BuildContext context, HomeState state) {
    if (state is HomeJoinClassSuccess) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Berhasil gabung kelas')));
      _joinClassTokenController.clear();
      context.read<CourseBloc>().add(const RefreshCoursesEvent());
    } else if (state is HomeJoinClassFailure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: const [
                  Text(
                    'Lihat semua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.brandPrimary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInstructorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode Instruktur Aktif',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Kelola materi, kursus, dan konten untuk peserta.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<HomeBloc, HomeState>(
        listener: _handleHomeBlocListener,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with greeting and search
                HomeHeader(searchController: _searchController),
                if (widget.accountRole == 'instructor')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppMeasures.paddingLarge,
                      AppMeasures.paddingLarge,
                      AppMeasures.paddingLarge,
                      0,
                    ),
                    child: _buildInstructorBanner(),
                  ),
                SizedBox(height: AppMeasures.paddingLarge),

                // Single BlocBuilder for entire content area
                // Calculate stats once and pass to multiple widgets
                BlocBuilder<CourseBloc, CourseState>(
                  builder: (context, state) {
                    // Handle loading state
                    if (state is CourseLoading) {
                      return const SizedBox(
                        height: 400,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.brandPrimary,
                          ),
                        ),
                      );
                    }

                    // Handle error state
                    if (state is CourseFailure) {
                      return SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            state.message,
                            style: const TextStyle(
                              color: AppColors.brandPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    // Handle loaded state
                    if (state is! CourseLoaded) {
                      return const SizedBox.shrink();
                    }

                    // Calculate stats ONCE for all widgets
                    final stats = HomeStatsEntity.fromCourses(state.courses);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Statistics Grid
                        HomeStatisticsGrid(stats: stats),
                        SizedBox(height: AppMeasures.paddingXLarge),

                        // Section Title
                        _buildSectionHeader(
                          AppStrings.myCourses,
                          onSeeAll: _goToCourseList,
                        ),
                        const SizedBox(height: 12),

                        // Recommended Courses
                        HomeRecommendedCourses(
                          courseState: state,
                          onNavigateToCourseList: _goToCourseList,
                        ),
                        const SizedBox(height: 16),

                        // Extra Sections (Join Class, Certificates)
                        HomeExtraSections(
                          tokenController: _joinClassTokenController,
                          stats: stats,
                          completedCourses: stats.completedCourseList,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: AppMeasures.paddingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
