import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Selectable card used for the single-choice options in registration
/// (program, gender, occupation). Pure presentation — selection state and the
/// tap handler are provided by the caller.
class RegisterChoiceCard extends StatelessWidget {
  static const Color _selectedTint = Color(0xFFFFF1F1);

  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;

  const RegisterChoiceCard({
    super.key,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
        : const EdgeInsets.all(14);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: padding,
          decoration: BoxDecoration(
            color: selected ? _selectedTint : AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.brandPrimary : AppColors.borderDefault,
              width: 1.5,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.brandPrimary.withValues(alpha: 0.10),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: compact
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.brandPrimary : Colors.white,
                  border: Border.all(
                    color: selected
                        ? AppColors.brandPrimary
                        : AppColors.borderDefault,
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: compact
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: compact ? 13 : 14,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? AppColors.brandPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                    if (!compact && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                          height: 1.3,
                        ),
                      ),
                    ],
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

/// Inline validation message shown beneath a group of choice cards.
class RegisterFieldError extends StatelessWidget {
  final String? message;

  const RegisterFieldError({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        message!,
        style: const TextStyle(color: Colors.red, fontSize: 12),
      ),
    );
  }
}
