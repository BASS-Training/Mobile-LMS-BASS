import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/utils/lesson_route_resolver.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_bloc.dart';
import 'package:lms_mobile_app/src/features/courses/presentation/bloc/course/course_state.dart';
import 'package:lms_mobile_app/src/features/notifications/domain/entities/app_notification.dart';
import 'package:lms_mobile_app/src/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// The notification center: a merged, date-sorted feed of discussion replies,
/// grades, new materials, and announcements. Tapping an item marks it read.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().load();
  }

  /// Marks the notification read, then deep-links to its target page:
  ///  - discussion_reply → utas diskusi materi (highlight balasan itu)
  ///  - grade / new_content → layar materi terkait (dicari dari CourseBloc via
  ///    contentId, tanpa endpoint tambahan)
  ///  - announcement / lainnya (atau materi tak ketemu) → sheet detail
  void _onTap(AppNotification item) {
    context.read<NotificationsCubit>().markRead(item);
    final contentId = item.contentId ?? '';

    switch (item.category) {
      case 'discussion_reply':
        if (contentId.isNotEmpty) {
          context.push(
            AppRoutes.discussionThread,
            extra: {
              'contentId': item.contentId,
              'lessonTitle': item.lessonTitle ?? '',
              'courseTitle': item.courseTitle,
              'highlightDiscussionId': item.discussionId,
            },
          );
          return;
        }
      case 'new_submission':
        if (_openGrading(item)) return;
      case 'grade':
      case 'new_content':
        if (contentId.isNotEmpty && _openContent(contentId)) return;
      case 'announcement':
        break; // tak punya materi → tampilkan detail
      default:
        if (contentId.isNotEmpty && _openContent(contentId)) return;
    }

    // Fallback: tampilkan isi notifikasi (mis. pengumuman, atau materi yang
    // tidak ada di daftar kursus yang dimuat).
    _showDetailSheet(item);
  }

  /// Cari materi (content) di kursus yang sudah dimuat CourseBloc lalu buka layar
  /// detailnya sesuai tipe. Return false bila tidak ditemukan.
  bool _openContent(String contentId) {
    final state = context.read<CourseBloc>().state;
    if (state is! CourseLoaded) return false;
    for (final course in state.courses) {
      final lessons = course.allLessons;
      for (var i = 0; i < lessons.length; i++) {
        if (lessons[i].id == contentId) {
          context.push(
            LessonRouteResolver.routeForType(lessons[i].type),
            extra: {
              'lesson': lessons[i],
              'course': course,
              'lessonIndex': i,
            },
          );
          return true;
        }
      }
    }
    return false;
  }

  /// Notifikasi "tugas baru" (instruktur) → langsung ke layar penilaian
  /// submission itu. Return false bila data tak lengkap.
  bool _openGrading(AppNotification item) {
    final submissionId = item.submissionId ?? '';
    if (submissionId.isEmpty) return false;
    switch (item.submissionType) {
      case 'essay':
        context.push(AppRoutes.instructorEssayGrading, extra: submissionId);
        return true;
      case 'case_study':
        context.push(AppRoutes.instructorCaseStudyGrading, extra: submissionId);
        return true;
      case 'document':
        context.push(
          AppRoutes.instructorDocumentGrading,
          extra: {
            'submissionId': submissionId,
            'contentId': item.contentId ?? '',
            'contentTitle': item.lessonTitle ?? '',
            'participantName': item.participantName ?? '',
          },
        );
        return true;
      default:
        return false;
    }
  }

  void _showDetailSheet(AppNotification item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _NotificationDetailSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandAppBar(
        title: 'Notifikasi',
        actions: [
          BlocBuilder<NotificationsCubit, NotificationsState>(
            buildWhen: (a, b) => a.unreadCount != b.unreadCount,
            builder: (context, state) {
              if (state.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => context.read<NotificationsCubit>().markAllRead(),
                child: const Text(
                  'Baca semua',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsCubit, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.loading ||
              state.status == NotificationsStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            );
          }
          if (state.status == NotificationsStatus.error) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat notifikasi',
              message: state.error ?? 'Terjadi kesalahan.',
              actionLabel: 'Coba lagi',
              onAction: () => context.read<NotificationsCubit>().load(),
            );
          }
          if (state.items.isEmpty) {
            return RefreshIndicator(
              color: AppColors.brandPrimary,
              onRefresh: () => context.read<NotificationsCubit>().load(),
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(
                    illustration:
                        'assets/illustrations/empty_notifications.svg',
                    icon: Icons.notifications_none_rounded,
                    title: 'Belum ada notifikasi',
                    message:
                        'Balasan diskusi, nilai yang keluar, materi baru, dan pengumuman akan muncul di sini.',
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.brandPrimary,
            onRefresh: () => context.read<NotificationsCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = state.items[i];
                return _NotificationTile(
                  item: item,
                  onTap: () => _onTap(item),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  ({IconData icon, Color color}) get _visual => _categoryVisual(item.category);

  @override
  Widget build(BuildContext context) {
    final v = _visual;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isRead
                ? AppColors.surface
                : v.color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isRead
                  ? AppColors.borderSubtle
                  : v.color.withValues(alpha: 0.30),
            ),
            boxShadow: AppShadows.xs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: v.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(v.icon, color: v.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: item.isRead
                                  ? FontWeight.w700
                                  : FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!item.isRead)
                          Container(
                            width: 9,
                            height: 9,
                            margin: const EdgeInsets.only(left: 6, top: 2),
                            decoration: BoxDecoration(
                              color: v.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _relativeTime(item.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

({IconData icon, Color color}) _categoryVisual(String category) {
  switch (category) {
    case 'discussion_reply':
      return (icon: Icons.forum_rounded, color: const Color(0xFF3B82F6));
    case 'grade':
      return (icon: Icons.workspace_premium_rounded, color: AppColors.success);
    case 'new_submission':
      return (icon: Icons.rate_review_rounded, color: AppColors.warning);
    case 'new_content':
      return (icon: Icons.menu_book_rounded, color: AppColors.brandText);
    case 'announcement':
      return (icon: Icons.campaign_rounded, color: AppColors.warning);
    default:
      return (icon: Icons.notifications_rounded, color: AppColors.slate);
  }
}

String _relativeTime(DateTime? time) {
  if (time == null) return '';
  final diff = DateTime.now().difference(time);
  if (diff.inSeconds < 60) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  if (diff.inDays < 7) return '${diff.inDays} hari lalu';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} bulan lalu';
  return '${(diff.inDays / 365).floor()} tahun lalu';
}

/// Sheet detail untuk notifikasi tanpa halaman tujuan (mis. pengumuman) atau
/// bila materi terkait tidak ditemukan di kursus yang dimuat.
class _NotificationDetailSheet extends StatelessWidget {
  final AppNotification item;

  const _NotificationDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final v = _categoryVisual(item.category);
    final ctx = [
      if ((item.courseTitle ?? '').isNotEmpty) item.courseTitle!,
      if ((item.lessonTitle ?? '').isNotEmpty) item.lessonTitle!,
    ].join(' · ');
    final time = _relativeTime(item.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: v.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(v.icon, color: v.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.25,
                        ),
                      ),
                      if (time.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (ctx.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 14,
                      color: AppColors.brandText,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        ctx,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              item.message,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
