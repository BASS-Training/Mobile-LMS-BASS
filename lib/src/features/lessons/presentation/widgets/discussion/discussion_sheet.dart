import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

import 'discussion_panel.dart';

/// Bottom-sheet panel showing the discussion (topics + replies) for a lesson.
/// Expects a [DiscussionCubit] provided above it (see `DiscussionButton`).
class DiscussionSheet extends StatelessWidget {
  final String lessonTitle;

  const DiscussionSheet({super.key, required this.lessonTitle});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                _buildHeader(context),
                Divider(height: 1, color: AppColors.borderSubtle),
                Expanded(
                  child: DiscussionPanel(scrollController: scrollController),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 8, 8),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderDefault,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.forum_rounded, color: AppColors.brandText),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diskusi',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      lessonTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
