import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Reusable gradient AppBar for all lesson screens.
///
/// All lesson types share the same structure: course title as main title,
/// a small subtitle label (e.g. 'VIDEO PLAYER'), a gradient background,
/// back arrow and optional hamburger menu.
class LessonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String courseTitle;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onBack;
  final VoidCallback? onMenuTap;

  /// Optional leading-of-menu action (e.g. the discussion icon). Kept generic so
  /// this shared widget stays feature-agnostic.
  final Widget? action;

  const LessonAppBar({
    super.key,
    required this.courseTitle,
    required this.subtitle,
    this.gradientColors = const [AppColors.red, AppColors.tomato],
    required this.onBack,
    this.onMenuTap,
    this.action,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            courseTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: GestureDetector(
        onTap: onBack,
        child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
      ),
      actions: [
        if (action != null) action!,
        if (onMenuTap != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: onMenuTap,
              child: const Icon(Icons.menu_rounded, color: Colors.white),
            ),
          ),
      ],
    );
  }
}
