import 'package:equatable/equatable.dart';

import '../../../domain/entities/game_score.dart';
import '../../../domain/entities/overall_game_stats.dart';

abstract class GamesHubState extends Equatable {
  const GamesHubState();

  @override
  List<Object?> get props => [];
}

class GamesHubInitial extends GamesHubState {
  const GamesHubInitial();
}

class GamesHubLoading extends GamesHubState {
  const GamesHubLoading();
}

class GamesHubLoaded extends GamesHubState {
  /// Score records keyed by gameId. Only contains games that have been played;
  /// the screen falls back to an empty record for catalog entries not present.
  final Map<String, GameScore> scoresById;
  final OverallGameStats overall;

  const GamesHubLoaded({required this.scoresById, required this.overall});

  GameScore scoreFor(String gameId) =>
      scoresById[gameId] ?? GameScore.empty(gameId);

  @override
  List<Object?> get props => [scoresById, overall];
}

class GamesHubFailure extends GamesHubState {
  final String message;

  const GamesHubFailure(this.message);

  @override
  List<Object?> get props => [message];
}
