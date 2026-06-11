import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Shared app bar for the mini games: title + sound toggle + a "Ulang" (restart)
/// action. Keeps each game screen free of duplicated chrome. Colors are
/// parameterised so games with their own palette (e.g. 2048's beige) can opt in.
class GameActionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color accent;
  final bool soundMuted;
  final VoidCallback onToggleSound;
  final VoidCallback onRestart;

  /// Whether to show the restart action (usually gated on the game being ready).
  final bool showRestart;

  final Color background;
  final Color foreground;

  const GameActionAppBar({
    super.key,
    required this.title,
    required this.accent,
    required this.soundMuted,
    required this.onToggleSound,
    required this.onRestart,
    this.showRestart = true,
    this.background = AppColors.background,
    this.foreground = AppColors.textPrimary,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: background,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: foreground,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
      ),
      actions: [
        IconButton(
          onPressed: onToggleSound,
          tooltip: soundMuted ? 'Nyalakan suara' : 'Matikan suara',
          icon: Icon(
            soundMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          ),
        ),
        if (showRestart)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: onRestart,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Ulang'),
              style: TextButton.styleFrom(foregroundColor: accent),
            ),
          ),
      ],
    );
  }
}
