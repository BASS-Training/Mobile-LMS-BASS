import 'package:flutter/material.dart';
import '../styles/styles.dart';

/// Generic reusable list tile widget untuk berbagai keperluan
/// Bisa dipakai untuk: lessons, certificates, courses, profile items, dll
///
/// Menggantikan: LessonTile, CertificateListTile, dan tile widgets lainnya
class AppListTile extends StatelessWidget {
  /// Title text
  final String title;

  /// Subtitle text (optional)
  final String? subtitle;

  /// Leading widget (biasanya icon atau circle indicator)
  final Widget? leading;

  /// Trailing widget (biasanya icon atau badge)
  final Widget? trailing;

  /// Callback saat tile di-tap
  final VoidCallback onTap;

  /// Background color
  final Color? backgroundColor;

  /// Show border atau tidak
  final bool showBorder;

  /// Border color
  final Color? borderColor;

  /// Max lines untuk title
  final int titleMaxLines;

  /// Max lines untuk subtitle
  final int subtitleMaxLines;

  /// Is tile disabled
  final bool isDisabled;

  /// Custom padding
  final EdgeInsets? padding;

  /// Custom margin
  final EdgeInsets? margin;

  const AppListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    required this.onTap,
    this.backgroundColor,
    this.showBorder = true,
    this.borderColor,
    this.titleMaxLines = 2,
    this.subtitleMaxLines = 1,
    this.isDisabled = false,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: isDisabled
            ? AppColors.background
            : (backgroundColor ?? Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: showBorder
            ? Border.all(color: borderColor ?? AppColors.border, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // Leading widget
                if (leading != null) ...[leading!, const SizedBox(width: 12)],

                // Title & subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: titleMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDisabled
                              ? AppColors.textLight
                              : AppColors.text,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          maxLines: subtitleMaxLines,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDisabled
                                ? AppColors.textLighter
                                : AppColors.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing widget
                if (trailing != null) ...[const SizedBox(width: 12), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper untuk create leading circle indicator
class CircleIndicator extends StatelessWidget {
  final String label;
  final Gradient? gradient;
  final Color? color;
  final bool isCompleted;
  final double size;
  final TextStyle? textStyle;

  const CircleIndicator({
    super.key,
    required this.label,
    this.gradient,
    this.color,
    this.isCompleted = false,
    this.size = 40,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient:
            gradient ??
            (isCompleted
                ? LinearGradient(
                    colors: [
                      AppColors.success,
                      AppColors.success.withOpacity(0.7),
                    ],
                  )
                : LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  )),
        color: color,
      ),
      child: Center(
        child: isCompleted
            ? Icon(Icons.check, color: Colors.white, size: size * 0.5)
            : Text(
                label,
                style:
                    textStyle ??
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: size * 0.4,
                    ),
              ),
      ),
    );
  }
}

/// Helper untuk create trailing icon
class TrailingIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final VoidCallback? onTap;

  const TrailingIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 24,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return Icon(icon, color: color ?? AppColors.textLight, size: size);
    }

    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color ?? AppColors.textLight, size: size),
    );
  }
}
