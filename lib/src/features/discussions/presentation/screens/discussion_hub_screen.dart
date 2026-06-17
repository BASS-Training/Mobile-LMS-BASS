import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/discussions/domain/entities/discussion_feed_item.dart';
import 'package:lms_mobile_app/src/features/discussions/presentation/cubit/discussion_feed_cubit.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/app_empty_state.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Discussion hub: a recent-activity feed of discussions across every course the
/// user is part of. Tapping an item opens that lesson's full discussion thread.
class DiscussionHubScreen extends StatelessWidget {
  const DiscussionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DiscussionFeedCubit>(
      create: (_) => ServiceLocator().locator<DiscussionFeedCubit>()..load(),
      child: const _DiscussionHubView(),
    );
  }
}

class _DiscussionHubView extends StatelessWidget {
  const _DiscussionHubView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Diskusi'),
      body: BlocBuilder<DiscussionFeedCubit, DiscussionFeedState>(
        builder: (context, state) {
          if (state.status == DiscussionFeedStatus.loading ||
              state.status == DiscussionFeedStatus.initial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandPrimary),
            );
          }
          if (state.status == DiscussionFeedStatus.error) {
            return AppEmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Gagal memuat diskusi',
              message: state.error ?? 'Terjadi kesalahan.',
              actionLabel: 'Coba lagi',
              onAction: () => context.read<DiscussionFeedCubit>().load(),
            );
          }
          if (state.items.isEmpty) {
            return RefreshIndicator(
              color: AppColors.brandPrimary,
              onRefresh: () => context.read<DiscussionFeedCubit>().load(),
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  AppEmptyState(
                    icon: Icons.forum_outlined,
                    title: 'Belum ada diskusi',
                    message:
                        'Diskusi dari semua kelas yang kamu ikuti akan muncul di sini. Mulai diskusi dari halaman materi.',
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.brandPrimary,
            onRefresh: () => context.read<DiscussionFeedCubit>().load(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final item = state.items[i];
                return _FeedTile(
                  item: item,
                  onTap: () => _openThread(context, item),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _openThread(
    BuildContext context,
    DiscussionFeedItem item,
  ) async {
    final cubit = context.read<DiscussionFeedCubit>();
    await context.push(
      AppRoutes.discussionThread,
      extra: {
        'contentId': item.contentId,
        'lessonTitle': item.lessonTitle,
        'courseTitle': item.courseTitle,
      },
    );
    // Reply counts may have changed after visiting the thread.
    await cubit.load();
  }
}

class _FeedTile extends StatelessWidget {
  final DiscussionFeedItem item;
  final VoidCallback onTap;

  const _FeedTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final context2 = [
      if (item.lessonTitle.isNotEmpty) item.lessonTitle,
      if (item.courseTitle.isNotEmpty) item.courseTitle,
    ].join(' · ');

    return Material(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.forum_rounded,
                  color: AppColors.brandPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (context2.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        context2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.brandPrimary,
                        ),
                      ),
                    ],
                    if (item.snippet.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.snippet,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 13,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.repliesCount} balasan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '· ${_relativeTime(item.lastActivityAt)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
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
    if (diff.inSeconds < 60) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} minggu lalu';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} bulan lalu';
    return '${(diff.inDays / 365).floor()} tahun lalu';
  }
}
