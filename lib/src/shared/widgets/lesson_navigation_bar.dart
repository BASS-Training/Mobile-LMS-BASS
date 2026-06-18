import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

/// Standard bottom navigation bar used by all lesson screens that have
/// a simple Previous / (Next | Selesai) flow.
///
/// Screens with custom flow (quiz questions, essay answers) can still
/// use this as a base or compose their own controls on top.
class LessonNavigationBar extends StatelessWidget {
  final bool canGoPrevious;
  final bool canGoNext;
  final VoidCallback? onPrevious;
  final VoidCallback onForward;
  final Color primaryColor;

  const LessonNavigationBar({
    super.key,
    required this.canGoPrevious,
    required this.canGoNext,
    this.onPrevious,
    required this.onForward,
    this.primaryColor = AppColors.brandPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          if (canGoPrevious) ...[
            Expanded(
              child: PressScale(
                child: OutlinedButton.icon(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Sebelumnya'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.borderDefault),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: PressScale(
              child: ElevatedButton.icon(
                onPressed: onForward,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shadowColor: primaryColor.withValues(alpha: 0.45),
                  elevation: 8,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: Icon(
                  canGoNext
                      ? Icons.arrow_forward_rounded
                      : Icons.check_rounded,
                ),
                label: Text(canGoNext ? 'Lanjut' : 'Selesai'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
