import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

/// Shared score/status box used across the mini-game screens (e.g. SKOR /
/// TERBAIK / the active target). [emphasised] paints the accent gradient
/// highlight; otherwise it's a plain surface card.
class GameInfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final bool emphasised;

  const GameInfoBox({
    super.key,
    required this.label,
    required this.value,
    required this.accent,
    this.emphasised = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: emphasised
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.lerp(accent, Colors.white, 0.20)!, accent],
              )
            : null,
        color: emphasised ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: emphasised ? accent : AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: emphasised
                ? accent.withValues(alpha: 0.32)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: emphasised ? 12 : 7,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: emphasised
                  ? Colors.white.withValues(alpha: 0.85)
                  : AppColors.textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: emphasised ? Colors.white : AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
