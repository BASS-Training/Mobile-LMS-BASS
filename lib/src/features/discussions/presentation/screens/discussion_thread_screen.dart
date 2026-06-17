import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/bloc/discussion/discussion_cubit.dart';
import 'package:lms_mobile_app/src/features/lessons/presentation/widgets/discussion/discussion_panel.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

/// Full-page discussion thread for a single lesson (backend content). Reuses the
/// same [DiscussionCubit] + [DiscussionPanel] as the lesson bottom-sheet, so the
/// hub and notification deep-links open the exact same thread.
class DiscussionThreadScreen extends StatelessWidget {
  final String contentId;
  final String lessonTitle;
  final String? courseTitle;
  final String? highlightDiscussionId;

  const DiscussionThreadScreen({
    super.key,
    required this.contentId,
    this.lessonTitle = '',
    this.courseTitle,
    this.highlightDiscussionId,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if (lessonTitle.isNotEmpty) lessonTitle,
      if (courseTitle != null && courseTitle!.isNotEmpty) courseTitle,
    ].join(' · ');

    return BlocProvider<DiscussionCubit>(
      create: (_) =>
          ServiceLocator().locator<DiscussionCubit>(param1: contentId)..load(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const BrandAppBar(title: 'Diskusi'),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              if (subtitle.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 16,
                        color: AppColors.brandPrimary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Divider(height: 1, color: AppColors.borderSubtle),
              Expanded(
                child: DiscussionPanel(
                  highlightDiscussionId: highlightDiscussionId,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
