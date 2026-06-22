import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
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

  /// Marks the notification read, then deep-links to its target where supported.
  /// For now only discussion replies open a destination (the lesson thread);
  /// other categories simply mark as read.
  void _onTap(AppNotification item) {
    context.read<NotificationsCubit>().markRead(item);

    if (item.category == 'discussion_reply' &&
        (item.contentId ?? '').isNotEmpty) {
      context.push(
        AppRoutes.discussionThread,
        extra: {
          'contentId': item.contentId,
          'lessonTitle': item.lessonTitle ?? '',
          'courseTitle': item.courseTitle,
          'highlightDiscussionId': item.discussionId,
        },
      );
    }
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

  ({IconData icon, Color color}) get _visual {
    switch (item.category) {
      case 'discussion_reply':
        return (icon: Icons.forum_rounded, color: const Color(0xFF3B82F6));
      case 'grade':
        return (icon: Icons.workspace_premium_rounded, color: AppColors.success);
      case 'new_content':
        return (icon: Icons.menu_book_rounded, color: AppColors.brandText);
      case 'announcement':
        return (icon: Icons.campaign_rounded, color: AppColors.warning);
      default:
        return (icon: Icons.notifications_rounded, color: AppColors.slate);
    }
  }

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
}
