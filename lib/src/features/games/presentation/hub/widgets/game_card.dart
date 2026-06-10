import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/widgets/press_scale.dart';

import '../../../domain/entities/game_score.dart';
import '../../registry/mini_game.dart';

/// A single game tile on the Games Hub grid. Shows the game's identity and, if
/// it's been played, the player's best score.
class GameCard extends StatelessWidget {
  final MiniGame game;
  final GameScore score;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.game,
    required this.score,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressScale(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: game.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(game.icon, color: game.accent, size: 26),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.play_circle_fill_rounded,
                    color: game.accent.withValues(alpha: 0.85),
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                game.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                game.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildScoreRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow() {
    if (!game.tracksHighScore) return const SizedBox.shrink();

    if (!score.hasBeenPlayed) {
      return Row(
        children: [
          const Icon(
            Icons.fiber_new_rounded,
            size: 16,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: 5),
          Text(
            'Belum dimainkan',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: game.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: 15, color: game.accent),
          const SizedBox(width: 5),
          Text(
            'Terbaik ${score.highScore}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: game.accent,
            ),
          ),
        ],
      ),
    );
  }
}
