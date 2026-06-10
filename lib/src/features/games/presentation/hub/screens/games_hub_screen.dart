import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/shared/styles/app_measures.dart';

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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: const Text(
          'Game & Hiburan',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
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
                const Text(
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
        gradient: const LinearGradient(
          colors: AppColors.brandGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Butuh penyegaran?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Rehat sejenak, main game, lalu lanjut belajar.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatPill(label: 'Game dimainkan', value: '${stats.gamesTried}'),
              const SizedBox(width: 10),
              _StatPill(label: 'Total main', value: '${stats.totalPlays}'),
              const SizedBox(width: 10),
              _StatPill(
                label: 'Total skor',
                value: '${stats.totalHighScore}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;

  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
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
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ),
    );
  }
}
