import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/src/features/home/domain/entities/home_stats.entity.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_achievements.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_continue_learning.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_daily_tip.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_header.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_recommended_courses.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_skeleton.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_summary_card.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_welcome_banner.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';

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

  void _goToCourseList() {
    if (!mounted) return;
    if (widget.onShowCourses != null) {
      widget.onShowCourses!.call();
      return;
    }
    context.push(AppRoutes.courses);
  }

  Future<void> _onRefresh() async {
    context.read<CourseBloc>().add(const RefreshCoursesEvent());
    await Future<void>.delayed(const Duration(milliseconds: 600));
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
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notifikasi akan segera hadir!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.brandPrimary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeader(
                  searchController: _searchController,
                  onNotificationsTap: _showComingSoon,
                ),
                if (widget.accountRole == 'instructor')
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppMeasures.paddingLarge,
                      AppMeasures.paddingMedium,
                      AppMeasures.paddingLarge,
                      0,
                    ),
                    child: _buildInstructorBanner(),
                  ),
                const SizedBox(height: AppMeasures.paddingLarge),
                _buildContent(),
                const SizedBox(height: AppMeasures.paddingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        if (state is CourseLoading) {
          return const HomeSkeleton();
        }

        if (state is CourseFailure) {
          return SizedBox(
            height: 220,
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

        if (state is! CourseLoaded) return const SizedBox.shrink();

        final ownedCourses = state.courses.where((c) => c.isOwned).toList();
        final stats = HomeStatsEntity.fromCourses(ownedCourses);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(child: HomeContinueLearning(courses: ownedCourses)),
            // New learners (no owned course) see a warm welcome instead of an
            // all-zero progress summary.
            if (ownedCourses.isNotEmpty) ...[
              const SizedBox(height: 16),
              FadeSlideIn(delayMs: 60, child: HomeSummaryCard(stats: stats)),
            ] else ...[
              const SizedBox(height: 4),
              const FadeSlideIn(delayMs: 60, child: HomeWelcomeBanner()),
            ],
            const SizedBox(height: 18),
            FadeSlideIn(
              delayMs: 100,
              child: HomeQuickActions(onShowCourses: _goToCourseList),
            ),
            const SizedBox(height: 22),
            FadeSlideIn(
              delayMs: 140,
              child: _buildSectionHeader('Kursus Saya'),
            ),
            const SizedBox(height: 12),
            FadeSlideIn(
              delayMs: 160,
              child: HomeRecommendedCourses(
                courses: ownedCourses,
                onNavigateToCourseList: _goToCourseList,
              ),
            ),
            const SizedBox(height: 20),
            FadeSlideIn(delayMs: 190, child: HomeAchievements(stats: stats)),
            const SizedBox(height: 16),
            const FadeSlideIn(delayMs: 220, child: HomeDailyTip()),
          ],
        );
      },
    );
  }
}
