import 'dart:math';

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
/// Overhang is trimmed (and tumbles away) so the tower narrows and speeds up —
/// miss entirely and it's game over. A timing/reflex game. Self-contained:
/// drives the pure [StackTowerEngine] from a vsync [Ticker] and renders a dusk
/// sky, faux-3D gradient blocks, falling debris and a "perfect" flash via
/// [_TowerPainter]. Score is tower height → direct high-score mapping.
class StackTowerScreen extends StatefulWidget {
  const StackTowerScreen({super.key});

  @override
  State<StackTowerScreen> createState() => _StackTowerScreenState();
}

class _StackTowerScreenState extends State<StackTowerScreen>
    with SingleTickerProviderStateMixin {
  static const Color _accent = Color(0xFF6C5CE7);
  static const String _gameId = GameIds.stackTower;
  static const double _blockHeight = 30;

  static const String _sfxStack = 'audio/sfx_stack.wav';
  static const String _sfxPerfect = 'audio/sfx_perfect.wav';
  static const String _sfxFall = 'audio/sfx_fall.wav';

  final _engine = StackTowerEngine();
  final _sl = ServiceLocator().locator;
  final _rng = Random();

  late final GetGameScore _getScore = _sl<GetGameScore>();
  late final SubmitGameResult _submitResult = _sl<SubmitGameResult>();

  late final GameSoundEffects _sfx;
  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastTick = Duration.zero;

  /// Eased camera position (in block-levels) that lerps toward the active level
  /// so the tower climbs smoothly instead of snapping.
  double _cameraLevel = 0;

  /// Trimmed/missed blocks currently tumbling off-screen.
  final List<_FallingPiece> _falling = [];

  /// 1→0 decay driving the "SEMPURNA!" flash after a perfect drop.
  double _perfectFlash = 0;

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
    _cameraLevel = _engine.activeLevel.toDouble();
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
    // Smoothly chase the active level (frame-rate independent easing).
    _cameraLevel +=
        (_engine.activeLevel - _cameraLevel) * (1 - exp(-dt * 12));
    for (final p in _falling) {
      p.t += dt / 1.0;
      p.rot += p.vrot * dt;
    }
    _falling.removeWhere((p) => p.t >= 1);
    if (_perfectFlash > 0) _perfectFlash = max(0, _perfectFlash - dt * 1.4);

    // Once everything has settled after a crash, stop burning frames.
    if (_engine.gameOver && _falling.isEmpty && _perfectFlash <= 0) {
      _ticker.stop();
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleSound() async {
    final muted = !_soundMuted;
    setState(() => _soundMuted = muted);
    _sfx.muted = muted;
    await LocalStorage.setGameSoundMuted(muted);
  }

  void _onDrop() {
    if (_engine.gameOver) return;
    final aLeft = _engine.activeLeft;
    final aWidth = _engine.activeWidth;
    final aRight = aLeft + aWidth;
    final dropLevel = _engine.activeLevel;

    final result = _engine.drop();
    switch (result) {
      case DropResult.stacked:
        _sfx.play(_sfxStack);
        HapticFeedback.lightImpact();
        _spawnOverhang(dropLevel, aLeft, aRight);
        setState(() {});
      case DropResult.perfect:
        _sfx.play(_sfxPerfect);
        HapticFeedback.mediumImpact();
        _perfectFlash = 1;
        setState(() {});
      case DropResult.gameOver:
        // The whole active block missed — let it tumble.
        _falling.add(
          _FallingPiece(
            level: dropLevel,
            left: aLeft,
            width: aWidth,
            color: _levelBase(dropLevel),
            vx: _rng.nextDouble() * 0.2 - 0.1,
            vrot: _rng.nextDouble() * 6 - 3,
          ),
        );
        _finishGame();
    }
  }

  /// Adds a falling sliver for the part of the dropped block that overhung the
  /// block below (whichever side stuck out).
  void _spawnOverhang(int level, double aLeft, double aRight) {
    final top = _engine.top; // the freshly placed (trimmed) block
    if (aLeft < top.left - 1e-6) {
      _falling.add(
        _FallingPiece(
          level: level,
          left: aLeft,
          width: top.left - aLeft,
          color: _levelBase(level),
          vx: -0.12 - _rng.nextDouble() * 0.1,
          vrot: -2 - _rng.nextDouble() * 3,
        ),
      );
    }
    if (aRight > top.right + 1e-6) {
      _falling.add(
        _FallingPiece(
          level: level,
          left: top.right,
          width: aRight - top.right,
          color: _levelBase(level),
          vx: 0.12 + _rng.nextDouble() * 0.1,
          vrot: 2 + _rng.nextDouble() * 3,
        ),
      );
    }
  }

  Future<void> _finishGame() async {
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
    _falling.clear();
    _perfectFlash = 0;
    _cameraLevel = _engine.activeLevel.toDouble();
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
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
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
                    const SizedBox(height: 14),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: _onDrop,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              RepaintBoundary(
                                child: CustomPaint(
                                  painter: _TowerPainter(
                                    engine: _engine,
                                    cameraLevel: _cameraLevel,
                                    falling: _falling,
                                    accent: _accent,
                                    blockHeight: _blockHeight,
                                  ),
                                ),
                              ),
                              if (!_gameOver && _engine.score == 0)
                                const _TapHint(),
                              if (_perfectFlash > 0)
                                _PerfectFlash(t: _perfectFlash),
                              if (_gameOver) _buildGameOverOverlay(),
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

  Widget _buildGameOverOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.42),
        alignment: Alignment.center,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutBack,
          builder: (context, t, child) => Transform.scale(
            scale: 0.82 + 0.18 * t.clamp(0.0, 1.0),
            child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            margin: const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.layers_rounded, color: _accent, size: 46),
                const SizedBox(height: 8),
                const Text(
                  'Menara Runtuh!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Tinggi ${_engine.score}  •  Terbaik $_best',
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
        ),
      ),
    );
  }
}

/// A trimmed/missed block fragment tumbling off-screen.
class _FallingPiece {
  final int level;
  final double left;
  final double width;
  final Color color;
  final double vx;
  final double vrot;
  double t = 0;
  double rot = 0;
  _FallingPiece({
    required this.level,
    required this.left,
    required this.width,
    required this.color,
    required this.vx,
    required this.vrot,
  });
}

/// Base colour for a block at [level] — a gentle hue drift up the tower.
Color _levelBase(int level) {
  final hue = (210 + level * 14) % 360;
  return HSVColor.fromAHSV(1, hue.toDouble(), 0.52, 0.95).toColor();
}

class _TowerPainter extends CustomPainter {
  final StackTowerEngine engine;
  final double cameraLevel;
  final List<_FallingPiece> falling;
  final Color accent;
  final double blockHeight;

  _TowerPainter({
    required this.engine,
    required this.cameraLevel,
    required this.falling,
    required this.accent,
    required this.blockHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintSky(canvas, size);

    final pw = size.width;
    final anchorBottom = size.height * 0.52;
    double bottomYFor(double level) =>
        anchorBottom + (cameraLevel - level) * blockHeight;

    // Placed blocks.
    for (var i = 0; i < engine.placed.length; i++) {
      final b = engine.placed[i];
      final bottomY = bottomYFor(i.toDouble());
      if (bottomY - blockHeight > size.height || bottomY < -blockHeight) {
        continue;
      }
      _paintFace(
        canvas,
        Rect.fromLTRB(b.left * pw, bottomY - blockHeight, b.right * pw, bottomY - 3),
        _levelBase(i),
      );
    }

    // Active (oscillating) block — accented and glowing.
    if (!engine.gameOver) {
      final bottomY = bottomYFor(engine.activeLevel.toDouble());
      _paintFace(
        canvas,
        Rect.fromLTRB(
          engine.activeLeft * pw,
          bottomY - blockHeight,
          (engine.activeLeft + engine.activeWidth) * pw,
          bottomY - 3,
        ),
        accent,
        glow: true,
      );
    }

    // Falling debris.
    for (final p in falling) {
      final baseBottom = bottomYFor(p.level.toDouble());
      final fall = Curves.easeIn.transform(p.t.clamp(0.0, 1.0)) * size.height;
      final cx = (p.left + p.width / 2) * pw + p.vx * p.t * pw;
      final cy = baseBottom - blockHeight / 2 + fall;
      final alpha = (1 - p.t).clamp(0.0, 1.0);
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(p.rot);
      _paintFace(
        canvas,
        Rect.fromCenter(
          center: Offset.zero,
          width: p.width * pw,
          height: blockHeight - 3,
        ),
        p.color,
        alpha: alpha,
      );
      canvas.restore();
    }
  }

  void _paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A2A5E), Color(0xFF5B5391), Color(0xFFC18BB2)],
          stops: [0, 0.55, 1],
        ).createShader(rect),
    );
    // Soft moon glow.
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.8, size.height * 0.18),
          radius: size.width * 0.28,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.18),
      size.width * 0.28,
      glow,
    );
  }

  /// Draws one block with a darker extruded base (faux-3D thickness), a
  /// vertical face gradient, a top highlight and a left gloss. [alpha] fades
  /// falling debris; [glow] adds a coloured halo for the active block.
  void _paintFace(
    Canvas canvas,
    Rect rect,
    Color base, {
    double alpha = 1,
    bool glow = false,
  }) {
    const r = Radius.circular(7);
    const depth = 6.0;

    if (glow) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(2), r),
        Paint()
          ..color = base.withValues(alpha: 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
    } else if (alpha > 0.95) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.translate(0, 4), r),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // Extruded base (darker, peeking below the front face).
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.translate(0, depth), r),
      Paint()..color = Color.lerp(base, Colors.black, 0.40)!.withValues(alpha: alpha),
    );

    // Front face gradient.
    final top = Color.lerp(base, Colors.white, 0.20)!.withValues(alpha: alpha);
    final mid = base.withValues(alpha: alpha);
    final bottom =
        Color.lerp(base, Colors.black, 0.22)!.withValues(alpha: alpha);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, r),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, mid, bottom],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );

    // Top highlight.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left + 4, rect.top + 3, max(0, rect.width - 8), 4),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.30 * alpha),
    );
    // Left gloss.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          rect.left + rect.width * 0.10,
          rect.top + 5,
          rect.width * 0.12,
          max(0, rect.height - 10),
        ),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.14 * alpha),
    );
  }

  @override
  bool shouldRepaint(_TowerPainter oldDelegate) => true;
}

/// The "SEMPURNA!" burst shown briefly after a perfect drop. [t] decays 1→0.
class _PerfectFlash extends StatelessWidget {
  final double t;
  const _PerfectFlash({required this.t});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.5),
      child: Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 1.0 + (1 - t) * 0.4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFC23D),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC23D).withValues(alpha: 0.6),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Text(
              'SEMPURNA!',
              style: TextStyle(
                color: Color(0xFF6B4E00),
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TapHint extends StatelessWidget {
  const _TapHint();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Ketuk untuk menjatuhkan balok',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
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
        gradient: emphasised
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color.lerp(accent, Colors.white, 0.20)!, accent],
              )
            : null,
        color: emphasised ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: emphasised ? accent : AppColors.borderSubtle,
        ),
        boxShadow: [
          BoxShadow(
            color: emphasised
                ? accent.withValues(alpha: 0.32)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: emphasised ? 12 : 7,
            offset: const Offset(0, 4),
          ),
        ],
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
