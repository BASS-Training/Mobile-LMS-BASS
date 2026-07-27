import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/instructor/domain/entities/instructor_entities.dart';
import 'package:lms_mobile_app/src/features/instructor/presentation/cubit/instructor_overview_cubit.dart';
import 'package:lms_mobile_app/src/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Home for instructors/admins — an action-oriented dashboard (grading + class
/// monitoring) instead of the participant's learning home. Metrics mirror the
/// web instructor/admin dashboard.
class InstructorDashboardScreen extends StatelessWidget {
  const InstructorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<InstructorDashboardCubit>(
          create: (_) =>
              ServiceLocator().locator<InstructorDashboardCubit>()..load(),
        ),
        // Global grading inbox — also powers the "recent submissions" feed.
        BlocProvider<GradingQueueCubit>(
          create: (_) =>
              ServiceLocator().locator<GradingQueueCubit>(param1: '')..load(),
        ),
      ],
      child: const _InstructorDashboardView(),
    );
  }
}

class _InstructorDashboardView extends StatelessWidget {
  const _InstructorDashboardView();

  Future<void> _refresh(BuildContext context) async {
    context.read<InstructorDashboardCubit>().load();
    await context.read<GradingQueueCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Kelas & Peserta'),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.brandPrimary,
          onRefresh: () => _refresh(context),
          child: BlocBuilder<InstructorDashboardCubit, InstructorDashboardState>(
            builder: (context, state) {
              if (state.status == InstructorStatus.loading ||
                  state.status == InstructorStatus.initial) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.brandPrimary,
                  ),
                );
              }
              if (state.status == InstructorStatus.error ||
                  state.data == null) {
                return ListView(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    AppEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Gagal memuat dashboard',
                      message: state.error ?? 'Terjadi kesalahan.',
                      actionLabel: 'Coba lagi',
                      onAction: () =>
                          context.read<InstructorDashboardCubit>().load(),
                    ),
                  ],
                );
              }

              final d = state.data!;
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  _header(d),
                  const SizedBox(height: 18),
                  _pendingHero(context, d),
                  const SizedBox(height: 16),
                  _statStrip(d),
                  const SizedBox(height: 24),
                  _sectionTitle(
                    d.isAdmin ? 'Semua Kelas' : 'Kelas yang Anda Ampu',
                  ),
                  const SizedBox(height: 12),
                  if (d.courses.isEmpty)
                    _infoCard('Belum ada kelas.')
                  else
                    ...d.courses.map((c) => _CourseCard(summary: c)),
                  const SizedBox(height: 24),
                  _sectionTitle('Submission Terbaru'),
                  const SizedBox(height: 12),
                  const _RecentFeed(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _header(InstructorDashboard d) {
    final initial = d.name.trim().isNotEmpty ? d.name.trim()[0].toUpperCase() : 'I';
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: AppColors.brandGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                d.name.isEmpty ? 'Halo 👋' : 'Halo, ${d.name} 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                d.isAdmin
                    ? 'Mode Admin · kelola & nilai semua kelas'
                    : 'Mode Instruktur · kelola & nilai peserta',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const _NotificationBell(),
      ],
    );
  }

  Widget _pendingHero(BuildContext context, InstructorDashboard d) {
    final none = d.pendingGrading == 0;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF5147), Color(0xFFE7140C), Color(0xFFC10000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.brand(AppColors.brandPrimary, opacity: 0.18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            none ? 'PENILAIAN' : 'PERLU DINILAI',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 10),
          if (none)
            const Text(
              'Semua sudah dinilai 🎉',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${d.pendingGrading}',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    'submission menunggu',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: none
                  ? null
                  : () => context.push(
                      AppRoutes.instructorGradingQueue,
                      extra: {'courseId': ''},
                    ),
              icon: const Icon(Icons.rate_review_rounded, size: 18),
              label: Text(none ? 'Tidak ada antrian' : 'Mulai Menilai'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.brandPrimary,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.6),
                disabledForegroundColor: AppColors.brandPrimary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statStrip(InstructorDashboard d) {
    return Row(
      children: [
        _statCard(
          icon: Icons.menu_book_rounded,
          color: AppColors.brandPrimary,
          value: '${d.totalCourses}',
          label: 'Kelas',
        ),
        const SizedBox(width: 12),
        _statCard(
          icon: Icons.groups_rounded,
          color: AppColors.info,
          value: '${d.totalParticipants}',
          label: 'Peserta',
        ),
        const SizedBox(width: 12),
        _statCard(
          icon: Icons.rate_review_rounded,
          color: AppColors.warning,
          value: '${d.pendingGrading}',
          label: 'Perlu nilai',
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppShadows.xs,
        ),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _infoCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
      ),
    );
  }
}

/// A course summary card; tapping opens a sheet to manage that class.
class _CourseCard extends StatelessWidget {
  final InstructorCourseSummary summary;

  const _CourseCard({required this.summary});

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  summary.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _sheetAction(
                  icon: Icons.groups_rounded,
                  label: 'Progres Peserta',
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push(
                      AppRoutes.instructorParticipants,
                      extra: {
                        'courseId': summary.id,
                        'courseTitle': summary.title,
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                _sheetAction(
                  icon: Icons.rate_review_rounded,
                  label: 'Penilaian',
                  badge: summary.pendingCount,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.push(
                      AppRoutes.instructorGradingQueue,
                      extra: {'courseId': summary.id},
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int badge = 0,
  }) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.brandText),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (badge > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openSheet(context),
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: AppShadows.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        summary.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                    if (summary.status.isNotEmpty) _statusChip(summary.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _miniStat(
                      Icons.groups_rounded,
                      '${summary.participantCount} peserta',
                      AppColors.info,
                    ),
                    const SizedBox(width: 16),
                    _miniStat(
                      Icons.rate_review_rounded,
                      summary.pendingCount > 0
                          ? '${summary.pendingCount} perlu nilai'
                          : 'Tuntas',
                      summary.pendingCount > 0
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final published = status == 'published';
    final color = published ? AppColors.success : AppColors.textTertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        published ? 'Terbit' : 'Draf',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

/// The "recent submissions" feed — top pending items from the global inbox.
class _RecentFeed extends StatelessWidget {
  const _RecentFeed();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GradingQueueCubit, GradingQueueState>(
      builder: (context, state) {
        if (state.status == InstructorStatus.loading ||
            state.status == InstructorStatus.initial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            ),
          );
        }
        final pending = state.items.where((i) => i.isPending).take(5).toList();
        if (pending.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              'Tidak ada submission yang menunggu dinilai.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          );
        }
        return Column(
          children: [
            for (final item in pending)
              _FeedTile(
                item: item,
                onTap: () async {
                  final cubit = context.read<GradingQueueCubit>();
                  final dash = context.read<InstructorDashboardCubit>();
                  await context.push(
                    item.isEssay
                        ? AppRoutes.instructorEssayGrading
                        : AppRoutes.instructorCaseStudyGrading,
                    extra: item.submissionId,
                  );
                  await cubit.load();
                  await dash.load();
                },
              ),
          ],
        );
      },
    );
  }
}

class _FeedTile extends StatelessWidget {
  final GradingQueueItem item;
  final VoidCallback onTap;

  const _FeedTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final typeColor = item.isEssay
        ? const Color(0xFF8B5CF6)
        : const Color(0xFFD97706);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    item.isEssay
                        ? Icons.edit_note_rounded
                        : Icons.assignment_rounded,
                    color: typeColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.participantName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.isEssay ? 'Essay' : 'Studi Kasus'} · ${item.contentTitle}',
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
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bell + unread badge for the instructor/admin dashboard. Reads the shared
/// NotificationsCubit singleton so the badge stays in sync with the feed.
class _NotificationBell extends StatefulWidget {
  const _NotificationBell();

  @override
  State<_NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<_NotificationBell> {
  final _cubit = ServiceLocator().locator<NotificationsCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.refreshUnreadCount();
  }

  Future<void> _open() async {
    await context.push(AppRoutes.notifications);
    await _cubit.refreshUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _open,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: BlocBuilder<NotificationsCubit, NotificationsState>(
          bloc: _cubit,
          buildWhen: (a, b) => a.unreadCount != b.unreadCount,
          builder: (context, state) => Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
                size: 24,
              ),
              if (state.unreadCount > 0)
                Positioned(
                  top: 7,
                  right: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.surface, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        state.unreadCount > 99 ? '99+' : '${state.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
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
