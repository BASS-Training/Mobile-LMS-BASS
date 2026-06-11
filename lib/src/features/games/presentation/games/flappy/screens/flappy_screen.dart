import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';
import 'package:lms_mobile_app/src/shared/styles/app_colors.dart';
import 'package:lms_mobile_app/src/features/games/presentation/widgets/game_action_app_bar.dart';

import '../../../../domain/entities/game_ids.dart';
import '../../../../domain/usecases/get_game_score.dart';
import '../../../../domain/usecases/submit_game_result.dart';
import '../../../audio/game_sound_effects.dart';
import '../logic/flappy_engine.dart';

/// Flappy-style game: tap to flap, weave through gaps in scrolling pipes. A
/// reflex game. Self-contained — drives the pure [FlappyEngine] from a vsync
/// [Ticker] and renders everything (sky, parallax clouds, scrolling ground,
/// gradient pipes, a tilting flapping bird) with a single [_ScenePainter].
/// Score is pipes cleared, mapping directly onto the shared "higher is better"
/// high-score model.
class FlappyScreen extends StatefulWidget {
  const FlappyScreen({super.key});

  @override
  State<FlappyScreen> createState() => _FlappyScreenState();
}

class _FlappyScreenState extends State<FlappyScreen>
    with SingleTickerProviderStateMixin {
  static const Color _accent = Color(0xFF4AA8FF);
  static const String _gameId = GameIds.flappy;

  static const String _sfxFlap = 'audio/sfx_flap.wav';
  static const String _sfxPoint = 'audio/sfx_point.wav';
  static const String _sfxCrash = 'audio/sfx_crash.wav';

  final _engine = FlappyEngine();
  final _sl = ServiceLocator().locator;

  late final GetGameScore _getScore = _sl<GetGameScore>();
  late final SubmitGameResult _submitResult = _sl<SubmitGameResult>();

  late final GameSoundEffects _sfx;
  late final Ticker _ticker = createTicker(_onTick);
  Duration _lastTick = Duration.zero;

  /// Seconds of wall-clock used to drive ambient animation (clouds, wing, bob).
  double _clock = 0;

  bool _ready = false;
  bool _gameOver = false;
  bool _soundMuted = false;
  int _best = 0;

  @override
  void initState() {
    super.initState();
    _soundMuted = LocalStorage.isGameSoundMuted();
    _sfx = GameSoundEffects(muted: _soundMuted);
    _sfx.load(const [_sfxFlap, _sfxPoint, _sfxCrash]);
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
      _ready = true;
    });
    _lastTick = Duration.zero;
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final dt = _lastTick == Duration.zero
        ? 0.0
        : (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0) return;
    _clock += dt;
    final result = _engine.tick(dt);
    if (result == FlapTick.scored) {
      _sfx.play(_sfxPoint);
      HapticFeedback.selectionClick();
    } else if (result == FlapTick.crashed) {
      _finishGame();
    }
    if (mounted) setState(() {});
  }

  Future<void> _toggleSound() async {
    final muted = !_soundMuted;
    setState(() => _soundMuted = muted);
    _sfx.muted = muted;
    await LocalStorage.setGameSoundMuted(muted);
  }

  void _onTapScene() {
    if (_gameOver) return;
    _engine.flap();
    _sfx.play(_sfxFlap);
    HapticFeedback.lightImpact();
  }

  Future<void> _finishGame() async {
    _ticker.stop();
    _sfx.play(_sfxCrash);
    HapticFeedback.heavyImpact();
    final updated = await _submitResult(gameId: _gameId, score: _engine.score);
    if (!mounted) return;
    setState(() {
      _best = updated.highScore;
      _gameOver = true;
    });
  }

  void _restart() {
    _engine.newGame();
    setState(() => _gameOver = false);
    _lastTick = Duration.zero;
    _ticker.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: GameActionAppBar(
        title: 'Flappy',
        accent: _accent,
        soundMuted: _soundMuted,
        onToggleSound: _toggleSound,
        onRestart: _restart,
        showRestart: _ready,
      ),
      body: !_ready
          ? const Center(child: CircularProgressIndicator(color: _accent))
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _onTapScene,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        RepaintBoundary(
                          child: CustomPaint(
                            painter: _ScenePainter(
                              engine: _engine,
                              clock: _clock,
                            ),
                          ),
                        ),
                        if (_engine.started && !_gameOver)
                          _ScoreBadge(score: _engine.score),
                        if (!_engine.started && !_gameOver) const _StartHint(),
                        if (_gameOver) _buildGameOverOverlay(),
                      ],
                    ),
                  ),
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
          margin: const EdgeInsets.symmetric(horizontal: 32),
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
              const Icon(Icons.flutter_dash, color: _accent, size: 48),
              const SizedBox(height: 8),
              const Text(
                'Gagal Terbang!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ResultStat(label: 'SKOR', value: '${_engine.score}'),
                  const SizedBox(width: 28),
                  _ResultStat(label: 'TERBAIK', value: '$_best'),
                ],
              ),
              const SizedBox(height: 20),
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

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  const _ResultStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final int score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.78),
      child: Text(
        '$score',
        style: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartHint extends StatelessWidget {
  const _StartHint();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, 0.3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.touch_app_rounded, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Ketuk untuk terbang',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Draws the whole scene each frame: sky → clouds → pipes → ground → bird.
class _ScenePainter extends CustomPainter {
  final FlappyEngine engine;
  final double clock;

  _ScenePainter({required this.engine, required this.clock});

  // Palette.
  static const _skyTop = Color(0xFF6FC0FF);
  static const _skyMid = Color(0xFFA6DCFF);
  static const _skyBottom = Color(0xFFDDF3FF);
  static const _pipeLight = Color(0xFF6CD45B);
  static const _pipeDark = Color(0xFF3E9E37);
  static const _pipeShade = Color(0xFF2F7E2A);
  static const _groundTop = Color(0xFF7BD36B);
  static const _groundBody = Color(0xFFC9A86B);
  static const _groundBodyDark = Color(0xFFB2925A);
  static const _birdLight = Color(0xFFFFD23F);
  static const _birdDark = Color(0xFFF59E0B);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _paintSky(canvas, size);
    _paintClouds(canvas, size);
    _paintPipes(canvas, size);
    _paintGround(canvas, size);
    _paintBird(canvas, w, h);
  }

  void _paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_skyTop, _skyMid, _skyBottom],
        stops: [0, 0.6, 1],
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    // Soft sun glow, top-right.
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withValues(alpha: 0.55), Colors.white.withValues(alpha: 0)],
      ).createShader(
        Rect.fromCircle(center: Offset(size.width * 0.82, size.height * 0.16), radius: size.width * 0.3),
      );
    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.16), size.width * 0.3, glow);
  }

  void _paintClouds(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.85);
    // Each cloud: base x (0..1), y fraction, scale, parallax speed.
    const defs = [
      [0.15, 0.16, 1.0, 0.018],
      [0.55, 0.10, 0.7, 0.026],
      [0.85, 0.26, 1.15, 0.014],
      [0.35, 0.32, 0.6, 0.03],
    ];
    for (final d in defs) {
      var fx = (d[0] - clock * d[3]) % 1.3;
      if (fx < 0) fx += 1.3;
      fx -= 0.15; // allow drifting off the left edge
      final cx = fx * w;
      final cy = d[1] * h;
      final s = d[2] * w * 0.07;
      canvas.drawCircle(Offset(cx, cy), s, cloud);
      canvas.drawCircle(Offset(cx + s * 0.9, cy + s * 0.25), s * 0.8, cloud);
      canvas.drawCircle(Offset(cx - s * 0.9, cy + s * 0.3), s * 0.75, cloud);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - s * 1.5, cy + s * 0.35, s * 3, s * 0.9),
          Radius.circular(s),
        ),
        cloud,
      );
    }
  }

  void _paintPipes(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final groundPx = FlappyEngine.groundY * h;
    final pipeW = FlappyEngine.pipeWidth * w;
    final gapHalfPx = FlappyEngine.gapHalf * h;
    const capH = 18.0;

    for (final p in engine.pipes) {
      final left = p.x * w;
      final gapCenter = p.gapCenter * h;
      final topEnd = gapCenter - gapHalfPx;
      final bottomStart = gapCenter + gapHalfPx;

      _drawPipeBody(canvas, left, 0, pipeW, topEnd);
      _drawPipeBody(canvas, left, bottomStart, pipeW, groundPx - bottomStart);
      // Caps at the gap ends.
      _drawPipeCap(canvas, left, topEnd - capH, pipeW, capH);
      _drawPipeCap(canvas, left, bottomStart, pipeW, capH);
    }
  }

  void _drawPipeBody(
    Canvas canvas,
    double left,
    double top,
    double width,
    double height,
  ) {
    if (height <= 0) return;
    final rect = Rect.fromLTWH(left, top, width, height);
    final body = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [_pipeLight, _pipeDark, _pipeShade],
        stops: [0, 0.55, 1],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      body,
    );
    // Glossy highlight stripe on the left third.
    final gloss = Paint()..color = Colors.white.withValues(alpha: 0.22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left + width * 0.12, top, width * 0.16, height),
        const Radius.circular(3),
      ),
      gloss,
    );
  }

  void _drawPipeCap(
    Canvas canvas,
    double left,
    double top,
    double width,
    double height,
  ) {
    final rect = Rect.fromLTWH(left - width * 0.08, top, width * 1.16, height);
    final cap = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [_pipeLight, _pipeDark, _pipeShade],
        stops: [0, 0.55, 1],
      ).createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(6)),
      cap,
    );
    final edge = Paint()..color = Colors.white.withValues(alpha: 0.25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(rect.left, top, rect.width, 4),
        const Radius.circular(3),
      ),
      edge,
    );
  }

  void _paintGround(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final groundPx = FlappyEngine.groundY * h;
    final rect = Rect.fromLTWH(0, groundPx, w, h - groundPx);
    final body = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_groundBody, _groundBodyDark],
      ).createShader(rect);
    canvas.drawRect(rect, body);

    // Grass lip.
    final grass = Paint()..color = _groundTop;
    canvas.drawRect(Rect.fromLTWH(0, groundPx, w, 8), grass);
    final grassShade = Paint()..color = const Color(0xFF5FB451);
    canvas.drawRect(Rect.fromLTWH(0, groundPx + 8, w, 3), grassShade);

    // Scrolling texture dashes.
    final dash = Paint()..color = _groundBodyDark.withValues(alpha: 0.55);
    const spacing = 26.0;
    final offset = (clock * 90) % spacing;
    for (double x = -offset; x < w; x += spacing) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, groundPx + 18, 12, 6),
          const Radius.circular(3),
        ),
        dash,
      );
    }
  }

  void _paintBird(Canvas canvas, double w, double h) {
    final rx = FlappyEngine.birdRadiusX * w;
    final ry = FlappyEngine.birdRadiusY * h;

    // Idle gentle bob before the run starts.
    final bob = engine.started ? 0.0 : sin(clock * 3) * h * 0.012;
    final cx = FlappyEngine.birdX * w;
    final cy = engine.birdY * h + bob;

    // Tilt with vertical velocity (up = nose up, falling = nose down).
    final angle = (engine.verticalVelocity * 0.9).clamp(-0.5, 1.0);

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle.toDouble());

    // Drop shadow.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, ry * 0.5), width: rx * 2, height: ry * 1.4),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    // Body.
    final bodyRect = Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2);
    canvas.drawOval(
      bodyRect,
      Paint()
        ..shader = const RadialGradient(
          colors: [_birdLight, _birdDark],
        ).createShader(bodyRect),
    );
    canvas.drawOval(
      bodyRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFFCB7A00),
    );

    // Belly highlight.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-rx * 0.1, ry * 0.45), width: rx * 1.2, height: ry * 0.9),
      Paint()..color = const Color(0xFFFFE9A3).withValues(alpha: 0.7),
    );

    // Wing (flaps faster while alive).
    final flapRate = engine.started && !engine.gameOver ? 18.0 : 6.0;
    final wingAngle = sin(clock * flapRate) * 0.5;
    canvas.save();
    canvas.translate(-rx * 0.15, ry * 0.05);
    canvas.rotate(wingAngle);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-rx * 0.25, 0), width: rx * 1.1, height: ry * 0.85),
      Paint()..color = const Color(0xFFF0930A),
    );
    canvas.restore();

    // Eye.
    final eyeCenter = Offset(rx * 0.45, -ry * 0.35);
    canvas.drawCircle(eyeCenter, ry * 0.36, Paint()..color = Colors.white);
    canvas.drawCircle(eyeCenter + Offset(rx * 0.12, 0), ry * 0.17, Paint()..color = const Color(0xFF222222));

    // Beak.
    final beak = Path()
      ..moveTo(rx * 0.85, -ry * 0.08)
      ..lineTo(rx * 1.45, ry * 0.05)
      ..lineTo(rx * 0.85, ry * 0.32)
      ..close();
    canvas.drawPath(beak, Paint()..color = const Color(0xFFFF7A00));

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScenePainter oldDelegate) => true;
}
