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
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/achievements/data/achievement_store.dart';
import 'package:lms_mobile_app/src/features/achievements/domain/achievement_catalog.dart';
import 'package:lms_mobile_app/src/features/achievements/presentation/widgets/achievement_celebration.dart';
import 'package:lms_mobile_app/src/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:lms_mobile_app/src/features/instructor/domain/entities/instructor_entities.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/instructor_overview_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
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

  Widget _buildInstructorBanner() {
    final isAdmin =
        widget.accountRole == 'admin' || widget.accountRole == 'super-admin';
    final title = isAdmin ? 'Mode Admin Aktif' : 'Mode Instruktur Aktif';
    const subtitle = 'Akses tambahan: nilai tugas, pantau progres, buka semua materi.';
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  subtitle,
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
                if (widget.canManage)
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
                widget.canManage ? _buildManagerContent() : _buildContent(),
                const SizedBox(height: AppMeasures.paddingXLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Konten Home untuk instruktur/admin: TIDAK menampilkan progres belajar
  /// pribadi (itu milik peserta). Sebagai gantinya: ringkasan "perlu dinilai"
  /// + daftar "Kelas Anda" (terbaru dulu, dari server).
  Widget _buildManagerContent() {
    return BlocProvider<InstructorDashboardCubit>(
      create: (_) =>
          ServiceLocator().locator<InstructorDashboardCubit>()..load(),
      child: BlocBuilder<InstructorDashboardCubit, InstructorDashboardState>(
        builder: (context, state) {
          final data = state.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppMeasures.paddingLarge,
                ),
                child: _managerHero(context, data),
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
              _buildSectionHeader(
                'Kelas Anda',
                onSeeAll: () => context.push(AppRoutes.instructorHub),
              ),
              const SizedBox(height: 12),
              _managerCourses(context, state.status, data),
            ],
          );
        },
      ),
    );
  }

  Widget _managerHero(BuildContext context, InstructorDashboard? data) {
    final pending = data?.pendingGrading ?? 0;
    final courses = data?.totalCourses ?? 0;
    final participants = data?.totalParticipants ?? 0;
    return GestureDetector(
      onTap: () => context.push(
        AppRoutes.instructorGradingQueue,
        extra: {'courseId': ''},
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: AppColors.brandGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppShadows.brand(AppColors.brandPrimary, opacity: 0.18),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.rate_review_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pending == 0
                        ? 'Semua sudah dinilai 🎉'
                        : '$pending submission menunggu dinilai',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$courses kelas · $participants peserta',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _managerCourses(
    BuildContext context,
    InstructorStatus status,
    InstructorDashboard? data,
  ) {
    if (status == InstructorStatus.loading ||
        status == InstructorStatus.initial) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.brandPrimary),
        ),
      );
    }
    final courses = data?.courses ?? const <InstructorCourseSummary>[];
    if (courses.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppMeasures.paddingLarge,
        ),
        child: Text(
          'Belum ada kelas.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      );
    }
    // courses sudah terbaru-dulu dari server.
    final preview = courses.take(5).toList();
    return Column(
      children: [
        for (final c in preview)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppMeasures.paddingLarge,
              0,
              AppMeasures.paddingLarge,
              10,
            ),
            child: _ManagerCourseTile(summary: c),
          ),
      ],
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

/// Kartu ringkas satu kelas untuk Home instruktur — ketuk untuk melihat progres
/// peserta di kelas itu.
class _ManagerCourseTile extends StatelessWidget {
  final InstructorCourseSummary summary;

  const _ManagerCourseTile({required this.summary});

  @override
  Widget build(BuildContext context) {
    final pending = summary.pendingCount;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(
          AppRoutes.instructorParticipants,
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
                    const SizedBox(height: 6),
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
                        const SizedBox(width: 12),
                        Icon(
                          Icons.rate_review_rounded,
                          size: 14,
                          color: pending > 0
                              ? AppColors.warning
                              : AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pending > 0 ? '$pending perlu nilai' : 'Tuntas',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: pending > 0
                                ? AppColors.warning
                                : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
