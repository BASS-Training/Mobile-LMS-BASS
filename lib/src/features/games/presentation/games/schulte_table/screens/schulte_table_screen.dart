import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

import '../../../../domain/entities/game_ids.dart';
import '../../../../domain/usecases/get_game_score.dart';
import '../../../../domain/usecases/submit_game_result.dart';
import '../../../audio/game_sound_effects.dart';
import '../logic/schulte_engine.dart';

/// Schulte Table: tap the numbers 1..N in order as fast as you can. A focus /
/// reaction speed game. Self-contained (drives the pure [SchulteEngine] with an
/// ephemeral game loop) and records a best score via the games use cases.
///
/// Scoring: the round's achievement is **points**, derived from speed so faster
/// solves score higher (`points = scale / seconds`). This keeps the shared
/// "higher is better" high-score model intact (the hub badge & totals stay
/// meaningful). The raw finishing time is shown in-game as feedback.
class SchulteTableScreen extends StatefulWidget {
  const SchulteTableScreen({super.key});

  @override
  State<SchulteTableScreen> createState() => _SchulteTableScreenState();
}

class _SchulteTableScreenState extends State<SchulteTableScreen> {
  static const Color _accent = Color(0xFF3DA9A3);
  static const String _gameId = GameIds.schulte;

  /// Tuning constant: a solve in this many seconds scores ~[_scoreScale] / s.
  /// e.g. 30s -> 300 pts, 20s -> 450 pts, 45s -> 200 pts.
  static const double _scoreScale = 9000;

  static const String _sfxCorrect = 'audio/sfx_correct.wav';
  static const String _sfxWrong = 'audio/sfx_wrong.wav';
  static const String _sfxWin = 'audio/sfx_win.wav';

  final _engine = SchulteEngine();
  final _sl = ServiceLocator().locator;

  late final GetGameScore _getScore = _sl<GetGameScore>();
  late final SubmitGameResult _submitResult = _sl<SubmitGameResult>();

  late final GameSoundEffects _sfx;

  final _stopwatch = Stopwatch();
  Timer? _ticker;

  bool _ready = false;
  bool _started = false;
  bool _finished = false;
  bool _soundMuted = false;
  int _best = 0; // best points
  bool _hasBest = false;
  int _lastPoints = 0;

  /// The number most recently tapped wrong, briefly flashed red. -1 when none.
  int _wrongValue = -1;
  Timer? _wrongTimer;

  @override
  void initState() {
    super.initState();
    _soundMuted = LocalStorage.isGameSoundMuted();
    _sfx = GameSoundEffects(muted: _soundMuted);
    _sfx.load(const [_sfxCorrect, _sfxWrong, _sfxWin]);
    _bootstrap();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _wrongTimer?.cancel();
    _sfx.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final score = await _getScore(_gameId);
    _engine.newGame();
    if (!mounted) return;
    setState(() {
      _best = score.highScore;
      _hasBest = score.hasBeenPlayed;
      _ready = true;
    });
  }

  Future<void> _toggleSound() async {
    final muted = !_soundMuted;
    setState(() => _soundMuted = muted);
    _sfx.muted = muted;
    await LocalStorage.setGameSoundMuted(muted);
  }

  double get _elapsedSeconds => _stopwatch.elapsedMilliseconds / 1000;

  void _startClock() {
    _started = true;
    _stopwatch
      ..reset()
      ..start();
    // Refresh the on-screen timer ~10x/sec; the stopwatch is the source of truth.
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) setState(() {});
    });
  }

  void _onTapCell(int value) {
    if (_finished) return;
    if (!_started) _startClock();

    final result = _engine.tap(value);
    switch (result) {
      case TapResult.correct:
        _sfx.play(_sfxCorrect);
        HapticFeedback.selectionClick();
        setState(() {});
      case TapResult.finished:
        _sfx.play(_sfxWin);
        HapticFeedback.mediumImpact();
        _finishGame();
      case TapResult.wrong:
        _sfx.play(_sfxWrong);
        HapticFeedback.heavyImpact();
        _flashWrong(value);
    }
  }

  void _flashWrong(int value) {
    _wrongTimer?.cancel();
    setState(() => _wrongValue = value);
    _wrongTimer = Timer(const Duration(milliseconds: 280), () {
      if (mounted) setState(() => _wrongValue = -1);
    });
  }

  Future<void> _finishGame() async {
    _stopwatch.stop();
    _ticker?.cancel();
    final seconds = _elapsedSeconds;
    final points = seconds > 0 ? (_scoreScale / seconds).round() : 0;
    _lastPoints = points;

    final updated = await _submitResult(gameId: _gameId, score: points);
    if (!mounted) return;
    setState(() {
      _best = updated.highScore;
      _hasBest = true;
      _finished = true;
    });
  }

  void _restart() {
    _wrongTimer?.cancel();
    _ticker?.cancel();
    _stopwatch
      ..stop()
      ..reset();
    _engine.newGame();
    setState(() {
      _started = false;
      _finished = false;
      _wrongValue = -1;
    });
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
          'Tabel Schulte',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: _toggleSound,
            tooltip: _soundMuted ? 'Nyalakan suara' : 'Matikan suara',
            icon: Icon(
              _soundMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            ),
          ),
          if (_ready)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Ulang'),
                style: TextButton.styleFrom(foregroundColor: _accent),
              ),
            ),
        ],
      ),
      body: !_ready
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildStatusRow(),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            children: [
                              _buildGrid(),
                              if (_finished) _buildFinishedOverlay(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        Expanded(
          child: _InfoBox(
            label: 'CARI',
            value: _finished ? '✓' : '${_engine.nextTarget}',
            accent: _accent,
            emphasised: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoBox(
            label: 'WAKTU',
            value: '${_elapsedSeconds.toStringAsFixed(1)}s',
            accent: _accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoBox(
            label: 'TERBAIK',
            value: _hasBest ? '$_best' : '–',
            accent: _accent,
          ),
        ),
      ],
    );
  }

  Widget _buildGrid() {
    final size = _engine.size;
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _engine.cells.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: size,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final value = _engine.cells[index];
        final found = value < _engine.nextTarget;
        final wrong = value == _wrongValue;
        return _SchulteCell(
          value: value,
          found: found,
          wrong: wrong,
          accent: _accent,
          onTap: _finished ? null : () => _onTapCell(value),
        );
      },
    );
  }

  Widget _buildFinishedOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, color: _accent, size: 44),
            const SizedBox(height: 8),
            const Text(
              'Selesai!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Waktu ${_elapsedSeconds.toStringAsFixed(1)} dtk  •  +$_lastPoints poin',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Terbaik: $_best poin',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _restart,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Main Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final bool emphasised;

  const _InfoBox({
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
        color: emphasised ? accent : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: emphasised ? accent : AppColors.borderSubtle),
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

class _SchulteCell extends StatelessWidget {
  final int value;
  final bool found;
  final bool wrong;
  final Color accent;
  final VoidCallback? onTap;

  const _SchulteCell({
    required this.value,
    required this.found,
    required this.wrong,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (wrong) {
      bg = AppColors.brandPrimary;
      fg = Colors.white;
    } else if (found) {
      bg = accent.withValues(alpha: 0.14);
      fg = accent.withValues(alpha: 0.45);
    } else {
      bg = AppColors.surface;
      fg = AppColors.textPrimary;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: found ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: wrong ? AppColors.brandPrimary : AppColors.borderSubtle,
          ),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              '$value',
              style: TextStyle(
                color: fg,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
