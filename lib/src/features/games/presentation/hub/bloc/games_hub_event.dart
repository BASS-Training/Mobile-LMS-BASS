import 'package:equatable/equatable.dart';

abstract class GamesHubEvent extends Equatable {
  const GamesHubEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) all game scores for the hub.
class LoadGamesHub extends GamesHubEvent {
  const LoadGamesHub();
}
