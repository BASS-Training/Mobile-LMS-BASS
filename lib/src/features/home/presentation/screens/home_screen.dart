import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_event.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/src/features/home/domain/entities/home_stats.entity.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_achievements.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_continue_grading.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_continue_learning.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_daily_tip.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_instructor_summary.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_header.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_recommended_courses.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_skeleton.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_summary_card.dart';
import 'package:lms_mobile_app/src/features/home/presentation/widgets/home_welcome_banner.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/achievements/data/achievement_store.dart';
import 'package:lms_mobile_app/src/features/achievements/domain/achievement_catalog.dart';
import 'package:lms_mobile_app/src/features/achievements/presentation/widgets/achievement_celebration.dart';
import 'package:lms_mobile_app/src/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/instructor_overview_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onShowCourses;
  final String accountRole;

  /// Instruktur/admin/super-admin: menampilkan banner mode pengelola dan
  /// pintasan akses tambahan (penilaian, panel instruktur) di quick actions.
  final bool canManage;

  const HomeScreen({
    super.key,
    this.onShowCourses,
    this.accountRole = 'participant',
    this.canManage = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _notifCubit = ServiceLocator().locator<NotificationsCubit>();
  final _achievementStore = ServiceLocator().locator<AchievementStore>();

  /// Guards the once-per-screen-mount achievement celebration check.
  bool _celebrationChecked = false;

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(const GetCoursesEvent());
    _notifCubit.refreshUnreadCount();
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
            style: TextStyle(
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
                children: [
                  Text(
                    'Lihat semua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.brandText,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.brandText,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Once stats are available, celebrate any achievement tier the learner has
  /// reached since they last saw it. Runs once per mount; the store seeds
  /// silently on first ever run so pre-existing progress isn't celebrated.
  void _maybeCelebrate(HomeStatsEntity stats) {
    if (_celebrationChecked) return;
    _celebrationChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final unlocked = await _achievementStore.detectNewlyUnlocked(
        buildAchievements(stats),
      );
      if (!mounted) return;
      await showAchievementCelebrations(context, unlocked);
    });
  }

  Future<void> _openNotifications() async {
    await context.push(AppRoutes.notifications);
    // Marking items read on the notification screen updates the shared singleton;
    // refresh once more in case anything changed server-side meanwhile.
    await _notifCubit.refreshUnreadCount();
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
                BlocBuilder<NotificationsCubit, NotificationsState>(
                  bloc: _notifCubit,
                  buildWhen: (a, b) => a.unreadCount != b.unreadCount,
                  builder: (context, state) => HomeHeader(
                    searchController: _searchController,
                    unreadCount: state.unreadCount,
                    onNotificationsTap: _openNotifications,
                  ),
                ),
                const SizedBox(height: AppMeasures.paddingLarge),
                widget.canManage ? _buildManagerContent() : _buildContent(),
                const SizedBox(height: AppMeasures.paddingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Konten Home untuk instruktur/admin: tata letaknya SAMA persis dengan
  /// peserta (hero → ringkasan → quick access → kartu kursus), hanya isinya yang
  /// disesuaikan untuk pengelolaan:
  ///  - "Lanjutkan Belajar" → "Lanjutkan Mengoreksi" (menuju antrian penilaian)
  ///  - ringkasan progres pribadi → ringkasan "perlu dinilai / kelas / peserta"
  ///  - kartu kursus = kelas yang bisa diakses instruktur (UI kartu yang sama)
  Widget _buildManagerContent() {
    return BlocProvider<InstructorDashboardCubit>(
      create: (_) =>
          ServiceLocator().locator<InstructorDashboardCubit>()..load(),
      child: BlocBuilder<InstructorDashboardCubit, InstructorDashboardState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideIn(
                child: HomeContinueGrading(
                  dashboard: state.data,
                  status: state.status,
                ),
              ),
              const SizedBox(height: 16),
              FadeSlideIn(
                delayMs: 60,
                child: HomeInstructorSummary(
                  dashboard: state.data,
                  status: state.status,
                ),
              ),
              const SizedBox(height: 18),
              FadeSlideIn(
                delayMs: 100,
                child: HomeQuickActions(
                  onShowCourses: _goToCourseList,
                  canManage: true,
                ),
              ),
              const SizedBox(height: 22),
              FadeSlideIn(
                delayMs: 140,
                child: _buildSectionHeader(
                  'Kelas Anda',
                  onSeeAll: () => context.push(AppRoutes.instructorHub),
                ),
              ),
              const SizedBox(height: 12),
              FadeSlideIn(delayMs: 160, child: _managerCourseRail()),
              const SizedBox(height: 20),
              const FadeSlideIn(delayMs: 200, child: HomeDailyTip()),
            ],
          );
        },
      ),
    );
  }

  /// Rail kartu kursus untuk instruktur — memakai UI kartu yang sama seperti
  /// peserta ([HomeRecommendedCourses]). Semua course yang dikembalikan API
  /// adalah kelas yang bisa diakses akun ini (backend sudah men-scope per peran).
  Widget _managerCourseRail() {
    return BlocBuilder<CourseBloc, CourseState>(
      builder: (context, state) {
        if (state is CourseLoading) {
          return const SizedBox(
            height: 250,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            ),
          );
        }
        if (state is! CourseLoaded) return const SizedBox(height: 8);
        if (state.courses.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppMeasures.paddingLarge,
            ),
            child: Text(
              'Belum ada kelas yang Anda kelola.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          );
        }
        return HomeRecommendedCourses(
          courses: state.courses,
          onNavigateToCourseList: _goToCourseList,
        );
      },
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
                style: TextStyle(color: AppColors.brandText, fontSize: 14),
              ),
            ),
          );
        }

        if (state is! CourseLoaded) return const SizedBox.shrink();

        final ownedCourses = state.courses.where((c) => c.isOwned).toList();
        final stats = HomeStatsEntity.fromCourses(ownedCourses);
        _maybeCelebrate(stats);

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
              child: HomeQuickActions(
                onShowCourses: _goToCourseList,
                canManage: widget.canManage,
                stats: stats,
              ),
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
