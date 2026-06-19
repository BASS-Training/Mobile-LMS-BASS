import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';
import 'package:lms_mobile_app/src/shared/styles/app_shadows.dart';
import 'package:lms_mobile_app/src/shared/widgets/animated_count.dart';
import 'package:lms_mobile_app/src/shared/widgets/brand_app_bar.dart';

import '../../../domain/entities/game_score.dart';
import '../../../domain/entities/overall_game_stats.dart';
import '../../registry/game_catalog.dart';
import '../bloc/games_hub_bloc.dart';
import '../bloc/games_hub_event.dart';
import '../bloc/games_hub_state.dart';
import '../widgets/game_card.dart';

/// Landing page for the games feature: an overall-progress header plus a grid
/// of every game in the catalog. Reloads scores whenever the user returns from
/// a game so high scores stay fresh.
class GamesHubScreen extends StatefulWidget {
  const GamesHubScreen({super.key});

  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GamesHubBloc>().add(const LoadGamesHub());
  }

  Future<void> _openGame(String route) async {
    await context.push(route);
    if (!mounted) return;
    // Refresh so a new high score earned in the game shows on the hub.
    context.read<GamesHubBloc>().add(const LoadGamesHub());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandAppBar(title: 'Game & Hiburan'),
      body: BlocBuilder<GamesHubBloc, GamesHubState>(
        builder: (context, state) {
          if (state is GamesHubFailure) {
            return _CenteredMessage(message: state.message);
          }

          final overall = state is GamesHubLoaded
              ? state.overall
              : const OverallGameStats(
                  gamesTried: 0,
                  totalPlays: 0,
                  totalHighScore: 0,
                );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppMeasures.paddingLarge,
              8,
              AppMeasures.paddingLarge,
              AppMeasures.paddingXLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OverallStatsHeader(stats: overall),
                const SizedBox(height: 22),
                Text(
                  'Pilih Game',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: GameCatalog.games.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.82,
                      ),
                  itemBuilder: (context, index) {
                    final game = GameCatalog.games[index];
                    final score = state is GamesHubLoaded
                        ? state.scoreFor(game.id)
                        : GameScore.empty(game.id);
                    return GameCard(
                      game: game,
                      score: score,
                      onTap: () => _openGame(game.route),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}

class _OverallStatsHeader extends StatelessWidget {
  final OverallGameStats stats;

  const _OverallStatsHeader({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brandSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.sports_esports_rounded,
                  color: AppColors.brandText,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Butuh penyegaran?',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Rehat sejenak, lalu lanjut belajar.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatPill(label: 'Game dimainkan', value: stats.gamesTried),
              const SizedBox(width: 10),
              _StatPill(label: 'Total main', value: stats.totalPlays),
              const SizedBox(width: 10),
              _StatPill(label: 'Total skor', value: stats.totalHighScore),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.brandSurfaceAlt,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            AnimatedCount(
              value: value,
              style: TextStyle(
                color: AppColors.brandText,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final String message;

  const _CenteredMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ),
    );
  }
}
