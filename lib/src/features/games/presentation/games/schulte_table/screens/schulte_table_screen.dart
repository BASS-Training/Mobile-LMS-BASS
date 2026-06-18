import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/features/games/presentation/widgets/game_action_app_bar.dart';
import 'package:lms_mobile_app/src/features/games/presentation/widgets/game_info_box.dart';
import 'package:lms_mobile_app/src/features/games/presentation/mixins/game_session_mixin.dart';

import '../../../../domain/entities/game_ids.dart';
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

class _SchulteTableScreenState extends State<SchulteTableScreen>
    with SingleTickerProviderStateMixin, GameSessionMixin {
  static const Color _accent = Color(0xFF3DA9A3);
  static const String _gameId = GameIds.schulte;

  /// Tuning constant: a solve in this many seconds scores ~[_scoreScale] / s.
  /// e.g. 30s -> 300 pts, 20s -> 450 pts, 45s -> 200 pts.
  static const double _scoreScale = 9000;

  static const String _sfxCorrect = 'audio/sfx_correct.wav';
  static const String _sfxWrong = 'audio/sfx_wrong.wav';
  static const String _sfxWin = 'audio/sfx_win.wav';

  final _engine = SchulteEngine();
  final _stopwatch = Stopwatch();
  Timer? _ticker;

  bool _ready = false;
  bool _started = false;
  bool _finished = false;
  int _best = 0; // best points
  bool _hasBest = false;
  int _lastPoints = 0;

  /// The number most recently tapped wrong, briefly flashed red. -1 when none.
  int _wrongValue = -1;
  Timer? _wrongTimer;

  /// Gentle pulse for the "CARI" target box to keep the eye on the goal.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    initGameSession(const [_sfxCorrect, _sfxWrong, _sfxWin]);
    _bootstrap();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _wrongTimer?.cancel();
    _pulse.dispose();
    disposeGameSession();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final score = await getScore(_gameId);
    _engine.newGame();
    if (!mounted) return;
    setState(() {
      _best = score.highScore;
      _hasBest = score.hasBeenPlayed;
      _ready = true;
    });
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
        sfx.play(_sfxCorrect);
        HapticFeedback.selectionClick();
        setState(() {});
      case TapResult.finished:
        sfx.play(_sfxWin);
        HapticFeedback.mediumImpact();
        _finishGame();
      case TapResult.wrong:
        sfx.play(_sfxWrong);
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

    final updated = await submitResult(gameId: _gameId, score: points);
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
      appBar: GameActionAppBar(
        title: 'Tabel Schulte',
        accent: _accent,
        soundMuted: soundMuted,
        onToggleSound: toggleGameSound,
        onRestart: _restart,
        showRestart: _ready,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF7F6), Color(0xFFF6F7F9)],
          ),
        ),
        child: !_ready
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
      ),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        Expanded(
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1.04).animate(
              CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
            ),
            child: GameInfoBox(
              label: 'CARI',
              value: _finished ? '✓' : '${_engine.nextTarget}',
              accent: _accent,
              emphasised: true,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GameInfoBox(
            label: 'WAKTU',
            value: '${_elapsedSeconds.toStringAsFixed(1)}s',
            accent: _accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GameInfoBox(
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
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.95 + 0.05 * t, child: child),
      ),
      child: GridView.builder(
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
      ),
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
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutBack,
          builder: (context, t, child) => Transform.scale(
            scale: 0.82 + 0.18 * t.clamp(0.0, 1.0),
            child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded, color: _accent, size: 44),
            const SizedBox(height: 8),
            Text(
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
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Terbaik: $_best poin',
              style: TextStyle(
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
    final radius = BorderRadius.circular(14);

    final BoxDecoration decoration;
    final Color fg;
    if (wrong) {
      decoration = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(AppColors.brandPrimary, Colors.white, 0.14)!,
            AppColors.brandPrimary,
          ],
        ),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPrimary.withValues(alpha: 0.40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
      fg = Colors.white;
    } else if (found) {
      decoration = BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: radius,
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      );
      fg = accent;
    } else {
      decoration = BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFEFF3F4)],
        ),
        borderRadius: radius,
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      );
      fg = AppColors.textPrimary;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: found ? null : onTap,
      child: AnimatedScale(
        scale: found ? 0.88 : (wrong ? 1.06 : 1.0),
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: decoration,
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: found
                ? Icon(
                    Icons.check_rounded,
                    key: const ValueKey('check'),
                    color: fg,
                    size: 26,
                  )
                : FittedBox(
                    key: ValueKey(value),
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
        ),
      ),
    );
  }
}
