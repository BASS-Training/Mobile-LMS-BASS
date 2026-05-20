import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/fade_slide_in.dart';
import '../../domain/entities/comment_entity.dart';

// Ubah menjadi StatelessWidget
class CommentItemWidget extends StatelessWidget {
  final CommentEntity comment;

  // Gunakan const constructor untuk performa maksimal
  const CommentItemWidget({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return FadeSlideIn(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF9FAFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.pearl.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.red.withValues(alpha: 0.15),
            child: Text(
              comment.userName.characters.first.toUpperCase(),
              style: const TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.timeLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.charcoal,
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}
