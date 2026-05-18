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
    } else if (state is HomeJoinClassFailure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppMeasures.paddingLarge),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.charcoal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mist,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: AppMeasures.paddingLarge,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.charcoal,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mode Instruktur Aktif',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Kelola materi, kursus, dan update konten untuk peserta.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: AppMeasures.paddingLarge),

                // Single BlocBuilder for entire content area
                // Calculate stats once and pass to multiple widgets
                BlocBuilder<CourseBloc, CourseState>(
                  builder: (context, state) {
                    // Handle loading state
                    if (state is CourseLoading) {
                      return SizedBox(
                        height: 400,
                        child: Center(child: CircularProgressIndicator()),
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
                              color: AppColors.crimson,
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
                        SizedBox(height: AppMeasures.paddingLarge),

                        // Section Title
                        _buildSectionTitle(AppStrings.myCourses),
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
