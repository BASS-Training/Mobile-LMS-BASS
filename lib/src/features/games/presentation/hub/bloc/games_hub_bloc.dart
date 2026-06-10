import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/overall_game_stats.dart';
import '../../../domain/usecases/get_all_game_scores.dart';
import 'games_hub_event.dart';
import 'games_hub_state.dart';

class GamesHubBloc extends Bloc<GamesHubEvent, GamesHubState> {
  final GetAllGameScores getAllGameScores;

  GamesHubBloc({required this.getAllGameScores})
    : super(const GamesHubInitial()) {
    on<LoadGamesHub>(_onLoad);
  }

  Future<void> _onLoad(LoadGamesHub event, Emitter<GamesHubState> emit) async {
    emit(const GamesHubLoading());
    try {
      final scores = await getAllGameScores();
      emit(
        GamesHubLoaded(
          scoresById: {for (final s in scores) s.gameId: s},
          overall: OverallGameStats.fromScores(scores),
        ),
      );
    } catch (e) {
      emit(GamesHubFailure('Gagal memuat data game: $e'));
    }
  }
}
