import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Standard centered empty state.
///
/// Two visual modes:
/// * an [illustration] (a brand-recolored unDraw SVG) for the friendly,
///   reference-style empty screens, or
/// * a fallback tinted circular [icon] for compact / secondary cases.
///
/// An optional [actionLabel] + [onAction] renders a primary CTA so an empty
/// screen can also nudge the user toward the next step.
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;

  /// Optional SVG asset path. When provided it replaces the icon circle.
  final String? illustration;

  /// Optional primary call-to-action shown beneath the message.
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_rounded,
    this.iconColor = AppColors.brandPrimary,
    this.illustration,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (illustration != null)
              SvgPicture.asset(
                illustration!,
                height: 168,
                fit: BoxFit.contain,
                semanticsLabel: title,
              )
            else
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.12),
                ),
                child: Icon(icon, size: 46, color: iconColor),
              ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: AppColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 22),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
