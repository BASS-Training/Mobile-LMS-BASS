import 'package:audioplayers/audioplayers.dart';

/// Reusable low-latency sound-effect player for mini games.
///
/// Each short clip is preloaded into its own [AudioPlayer] so effects fire (and
/// can overlap) with minimal delay. Deliberately tolerant: a missing or invalid
/// asset never throws — the effect is simply silent. Reusable by any game.
class GameSoundEffects {
  final double volume;
  bool _muted;

  final Map<String, AudioPlayer> _players = {};

  GameSoundEffects({bool muted = false, this.volume = 0.7}) : _muted = muted;

  bool get isMuted => _muted;
  set muted(bool value) => _muted = value;

  /// Preloads [assets] (paths relative to `assets/`, e.g. `audio/sfx_move.mp3`).
  Future<void> load(Iterable<String> assets) async {
    for (final asset in assets) {
      final player = AudioPlayer();
      try {
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setPlayerMode(PlayerMode.lowLatency);
        await player.setSource(AssetSource(asset));
        await player.setVolume(volume);
      } catch (_) {
        // Keep the (silent) player so play() safely no-ops.
      }
      _players[asset] = player;
    }
  }

  /// Plays [asset] from the start. No-op when muted or not loaded.
  Future<void> play(String asset) async {
    if (_muted) return;
    final player = _players[asset];
    if (player == null) return;
    try {
      await player.seek(Duration.zero);
      await player.resume();
    } catch (_) {}
  }

  Future<void> dispose() async {
    for (final player in _players.values) {
      try {
        await player.dispose();
      } catch (_) {}
    }
    _players.clear();
  }
}
