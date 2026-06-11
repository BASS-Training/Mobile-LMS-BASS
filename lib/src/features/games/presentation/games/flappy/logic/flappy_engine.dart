import 'dart:math';

/// One obstacle pair (a top + bottom pipe) with a gap the bird flies through.
/// [x] is the left edge in fractions of the play width (moves right→left);
/// [gapCenter] is the vertical centre of the gap in fractions of play height.
class Pipe {
  double x;
  final double gapCenter;
  bool passed;
  Pipe({required this.x, required this.gapCenter, this.passed = false});
}

/// Outcome of advancing the world by one tick.
enum FlapTick {
  /// Nothing notable happened this frame.
  none,

  /// The bird just cleared a pipe — score went up.
  scored,

  /// The bird hit a pipe or the ground — game over.
  crashed,
}

/// Pure Flappy-style logic — no Flutter, no timing widgets, no rendering.
///
/// Everything is normalized: x in fractions of play width, y in fractions of
/// play height (0 = top). The bird sits at a fixed [birdX] and only moves
/// vertically; the world scrolls toward it. The screen owns the clock (calls
/// [tick]) and the visuals; this engine just runs the physics and rules so it
/// can be unit tested in isolation.
class FlappyEngine {
  // Bird physics (per second).
  static const double birdX = 0.30;
  static const double birdRadiusX = 0.052;
  static const double birdRadiusY = 0.045;
  static const double gravity = 2;
  static const double flapVelocity = -0.66;
  static const double maxFallSpeed = 1.25;

  // World layout.
  static const double pipeWidth = 0.17;
  static const double gapHalf = 0.2;
  static const double groundY = 0.86; // ground occupies below this
  static const double pipeSpacing = 0.58; // distance between pipe pairs

  // Difficulty ramp.
  static const double speedBase = 0.44;
  static const double speedMax = 0.72;
  static const double speedPerScore = 0.012;

  final Random _rng;

  double birdY = 0.42;
  double velocity = 0;
  final List<Pipe> pipes = [];
  int score = 0;
  bool started = false;
  bool gameOver = false;

  double _distSinceSpawn = 0;

  FlappyEngine({Random? rng}) : _rng = rng ?? Random() {
    newGame();
  }

  double get speed => min(speedMax, speedBase + score * speedPerScore);

  /// Tilt hint for the view: how fast the bird is rising/falling.
  double get verticalVelocity => velocity;

  void newGame() {
    birdY = 0.42;
    velocity = 0;
    pipes.clear();
    score = 0;
    started = false;
    gameOver = false;
    // First pipe arrives shortly after the player starts.
    _distSinceSpawn = pipeSpacing - 0.32;
  }

  /// A flap: gives the bird an upward impulse (and starts the run on the first).
  void flap() {
    if (gameOver) return;
    started = true;
    velocity = flapVelocity;
  }

  /// Advances the world by [dt] seconds and reports the notable event.
  FlapTick tick(double dt) {
    if (gameOver || !started) return FlapTick.none;

    velocity = min(maxFallSpeed, velocity + gravity * dt);
    birdY += velocity * dt;

    // Ceiling: clamp, don't kill (more forgiving).
    if (birdY < birdRadiusY) {
      birdY = birdRadiusY;
      if (velocity < 0) velocity = 0;
    }

    // Ground: fatal.
    if (birdY + birdRadiusY >= groundY) {
      birdY = groundY - birdRadiusY;
      gameOver = true;
      return FlapTick.crashed;
    }

    // Scroll + spawn pipes.
    final spd = speed;
    for (final p in pipes) {
      p.x -= spd * dt;
    }
    _distSinceSpawn += spd * dt;
    if (_distSinceSpawn >= pipeSpacing) {
      _distSinceSpawn -= pipeSpacing;
      _spawnPipe();
    }
    pipes.removeWhere((p) => p.x + pipeWidth < -0.2);

    // Collision + scoring.
    var result = FlapTick.none;
    for (final p in pipes) {
      final overlapX =
          birdX + birdRadiusX > p.x && birdX - birdRadiusX < p.x + pipeWidth;
      if (overlapX) {
        final topGap = p.gapCenter - gapHalf;
        final bottomGap = p.gapCenter + gapHalf;
        if (birdY - birdRadiusY < topGap || birdY + birdRadiusY > bottomGap) {
          gameOver = true;
          return FlapTick.crashed;
        }
      }
      if (!p.passed && p.x + pipeWidth < birdX - birdRadiusX) {
        p.passed = true;
        score++;
        result = FlapTick.scored;
      }
    }
    return result;
  }

  void _spawnPipe() {
    const minCenter = gapHalf + 0.09;
    final maxCenter = groundY - gapHalf - 0.05;
    final gapCenter = minCenter + _rng.nextDouble() * (maxCenter - minCenter);
    pipes.add(Pipe(x: 1.15, gapCenter: gapCenter));
  }
}
