import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';

import '../../../../domain/entities/game_ids.dart';
import '../../../../domain/usecases/get_game_score.dart';
import '../../../../domain/usecases/submit_game_result.dart';
import '../../../audio/game_sound_effects.dart';
import '../logic/stack_tower_engine.dart';

/// Stack Tower: a horizontally sliding block; tap to drop it onto the stack.
/// Overhang is trimmed so the tower narrows and speeds up — miss entirely and
/// it's game over. A timing/reflex game. Self-contained: drives the pure
/// [StackTowerEngine] from a vsync [Ticker] and records the best height (score)
/// via the games use cases. Score is the tower height, so it maps directly onto
/// the shared "higher is better" high-score model — no encoding needed.
class StackTowerScreen extends StatefulWidget {
  const StackTowerScreen({super.key});

  @override
  State<StackTowerScreen> createState() => _StackTowerScreenState();
}

class _StackTowerScreenState extends State<StackTowerScreen>
    with SingleTickerProviderStateMixin {
  static const Color _accent = Color(0xFF6C5CE7);
  static const String _gameId = GameIds.stackTower;

  static const String _sfxStack = 'audio/sfx_stack.wav';
  static const String _sfxPerfect = 'audio/sfx_perfect.wav';
  static const String _sfxFall = 'audio/sfx_fall.wav';

  /// Pixel height of one block row on screen.
  static const double _blockHeight = 30;

  final _engine = StackTowerEngine();
  final _sl = ServiceLocator().locator;

  late final GetGameScore _getScore = _sl<GetGameScore>();
  late final SubmitGameResult _submitResult = _sl<SubmitGameResult>();

  late final GameSoundEffects _sfx;
  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastTick = Duration.zero;

  bool _ready = false;
  bool _gameOver = false;
  bool _soundMuted = false;
  int _best = 0;
  bool _hasBest = false;

  @override
  void initState() {
    super.initState();
    _soundMuted = LocalStorage.isGameSoundMuted();
    _sfx = GameSoundEffects(muted: _soundMuted);
    _sfx.load(const [_sfxStack, _sfxPerfect, _sfxFall]);
    _bootstrap();
  }

  @override
  void dispose() {
    _ticker.dispose();
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
    _startTicker();
  }

  void _startTicker() {
    _lastTick = Duration.zero;
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final dt = _lastTick == Duration.zero
        ? 0.0
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0) return;
    _engine.tick(dt);
    if (mounted) setState(() {});
  }

  Future<void> _toggleSound() async {
    final muted = !_soundMuted;
    setState(() => _soundMuted = muted);
    _sfx.muted = muted;
    await LocalStorage.setGameSoundMuted(muted);
  }

  void _onDrop() {
    if (_gameOver) return;
    final result = _engine.drop();
    switch (result) {
      case DropResult.stacked:
        _sfx.play(_sfxStack);
        HapticFeedback.lightImpact();
        setState(() {});
      case DropResult.perfect:
        _sfx.play(_sfxPerfect);
        HapticFeedback.mediumImpact();
        setState(() {});
      case DropResult.gameOver:
        _finishGame();
    }
  }

  Future<void> _finishGame() async {
    _ticker.stop();
    _sfx.play(_sfxFall);
    HapticFeedback.heavyImpact();
    final updated = await _submitResult(gameId: _gameId, score: _engine.score);
    if (!mounted) return;
    setState(() {
      _best = updated.highScore;
      _hasBest = true;
      _gameOver = true;
    });
  }

  void _restart() {
    _engine.newGame();
    setState(() => _gameOver = false);
    _startTicker();
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
          'Stack Tower',
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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            label: 'TINGGI',
                            value: '${_engine.score}',
                            accent: _accent,
                            emphasised: true,
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
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _onDrop,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: [
                              CustomPaint(
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                painter: _TowerPainter(
                                  engine: _engine,
                                  blockHeight: _blockHeight,
                                  accent: _accent,
                                ),
                              ),
                              if (!_gameOver && _engine.score == 0)
                                const _TapHint(),
                              if (_gameOver) _buildGameOverOverlay(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Positioned.fill(
      child: Container(
        color: AppColors.background.withValues(alpha: 0.88),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.layers_rounded, color: _accent, size: 44),
            const SizedBox(height: 8),
            const Text(
              'Menara Runtuh!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tinggi: ${_engine.score}  •  Terbaik: $_best',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
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

/// Paints the tower: the active oscillating block stays at a fixed anchor height
/// while placed blocks descend below it, giving an upward-scrolling effect.
class _TowerPainter extends CustomPainter {
  final StackTowerEngine engine;
  final double blockHeight;
  final Color accent;

  _TowerPainter({
    required this.engine,
    required this.blockHeight,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pw = size.width;
    // Active block's bottom sits ~45% down from the top; the stack falls away
    // below it as the tower climbs.
    final anchorBottom = size.height * 0.45;
    final radius = Radius.circular(blockHeight * 0.18);

    void drawBlock(StackBlock block, int level, {bool active = false}) {
      final bottomY = anchorBottom + (engine.activeLevel - level) * blockHeight;
      final topY = bottomY - blockHeight;
      if (topY > size.height || bottomY < 0) return; // off-screen
      final rect = Rect.fromLTRB(
        block.left * pw,
        topY,
        block.right * pw,
        bottomY - 2, // small gap between blocks
      );
      final paint = Paint()..color = _blockColor(level, active);
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
    }

    for (var i = 0; i < engine.placed.length; i++) {
      drawBlock(engine.placed[i], i);
    }
    if (!engine.gameOver) {
      drawBlock(
        StackBlock(engine.activeLeft, engine.activeWidth),
        engine.activeLevel,
        active: true,
      );
    }
  }

  Color _blockColor(int level, bool active) {
    if (active) return accent;
    // Gentle hue drift up the tower for a pleasing gradient.
    final hue = (200 + level * 12) % 360;
    return HSVColor.fromAHSV(1, hue.toDouble(), 0.45, 0.92).toColor();
  }

  @override
  bool shouldRepaint(_TowerPainter oldDelegate) => true;
}

class _TapHint extends StatelessWidget {
  const _TapHint();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment(0, -0.78),
      child: Text(
        'Ketuk untuk menjatuhkan balok',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
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
        border: Border.all(
          color: emphasised ? accent : AppColors.borderSubtle,
        ),
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
