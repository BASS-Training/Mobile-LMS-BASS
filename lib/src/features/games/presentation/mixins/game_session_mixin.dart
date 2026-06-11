import 'package:flutter/widgets.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';

import '../../domain/usecases/get_game_score.dart';
import '../../domain/usecases/submit_game_result.dart';
import '../audio/game_sound_effects.dart';

/// Shared session plumbing for the mini-game screens: resolves the scoring use
/// cases from the service locator and manages the (mute-aware) sound effects.
/// Lets each game [State] stay focused on its own loop and rendering instead of
/// re-declaring the same boilerplate.
///
/// Usage: `with GameSessionMixin`, then call [initGameSession] in `initState`
/// and [disposeGameSession] in `dispose`; use [getScore]/[submitResult] for
/// scoring, [sfx] to play effects, and wire the app bar to [soundMuted] +
/// [toggleGameSound].
mixin GameSessionMixin<T extends StatefulWidget> on State<T> {
  final _sl = ServiceLocator().locator;

  late final GetGameScore getScore = _sl<GetGameScore>();
  late final SubmitGameResult submitResult = _sl<SubmitGameResult>();

  late final GameSoundEffects sfx;
  bool soundMuted = false;

  /// Preloads the game's sound effects and restores the saved mute preference.
  void initGameSession(List<String> sfxAssets) {
    soundMuted = LocalStorage.isGameSoundMuted();
    sfx = GameSoundEffects(muted: soundMuted);
    sfx.load(sfxAssets);
  }

  /// Flips and persists the global game mute preference.
  Future<void> toggleGameSound() async {
    final muted = !soundMuted;
    setState(() => soundMuted = muted);
    sfx.muted = muted;
    await LocalStorage.setGameSoundMuted(muted);
  }

  void disposeGameSession() => sfx.dispose();
}
