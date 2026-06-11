import 'dart:math';

/// A single stacked block, expressed in normalized play-width units (0..1).
/// [left] is the left edge, [width] the block's width.
class StackBlock {
  final double left;
  final double width;
  const StackBlock(this.left, this.width);

  double get right => left + width;
}

/// Result of dropping the active block.
enum DropResult {
  /// Landed with some overlap; the block was trimmed to the overlap.
  stacked,

  /// Landed near-perfectly aligned; full width kept (and slightly regrown).
  perfect,

  /// Missed entirely — no overlap. The tower falls; game over.
  gameOver,
}

/// Pure Stack Tower logic — no Flutter, no timing widgets. The active block
/// oscillates horizontally ([tick]); the player [drop]s it onto the stack. The
/// overlap with the block below becomes the new block; the overhang is cut, so
/// the tower narrows until a miss ends the run. All coordinates are normalized
/// to a [playWidth] of 1.0 so the screen can scale freely. Framework-free for
/// easy unit testing.
class StackTowerEngine {
  static const double playWidth = 1.0;

  final double initialWidth;
  final double baseSpeed; // normalized units per second
  final double speedIncrement; // added per successful drop
  final double maxSpeed;
  final double perfectTolerance; // max misalignment counted as "perfect"
  final double perfectRegrow; // width regained on a perfect drop

  /// Placed blocks from bottom (index 0 = base) upward.
  List<StackBlock> placed = [];

  /// The moving block's current left edge and width.
  double activeLeft = 0;
  double activeWidth = 0;

  int _dir = 1; // +1 moving right, -1 moving left
  double speed = 0;
  int score = 0;
  bool gameOver = false;

  StackTowerEngine({
    this.initialWidth = 0.62,
    this.baseSpeed = 0.5,
    this.speedIncrement = 0.018,
    this.maxSpeed = 1.4,
    this.perfectTolerance = 0.012,
    this.perfectRegrow = 0.012,
  }) {
    newGame();
  }

  /// The block the active one will land on.
  StackBlock get top => placed.last;

  /// The level (row index) the active block currently occupies.
  int get activeLevel => placed.length;

  void newGame() {
    placed = [StackBlock((playWidth - initialWidth) / 2, initialWidth)];
    activeWidth = initialWidth;
    activeLeft = 0;
    _dir = 1;
    speed = baseSpeed;
    score = 0;
    gameOver = false;
  }

  /// Advances the oscillating active block by [dt] seconds, bouncing at edges.
  void tick(double dt) {
    if (gameOver) return;
    activeLeft += _dir * speed * dt;
    final maxLeft = playWidth - activeWidth;
    if (activeLeft <= 0) {
      activeLeft = 0;
      _dir = 1;
    } else if (activeLeft >= maxLeft) {
      activeLeft = maxLeft;
      _dir = -1;
    }
  }

  /// Drops the active block onto the stack and reports the outcome.
  DropResult drop() {
    if (gameOver) return DropResult.gameOver;

    final prev = top;
    final overlapLeft = max(activeLeft, prev.left);
    final overlapRight = min(activeLeft + activeWidth, prev.right);
    final overlap = overlapRight - overlapLeft;

    if (overlap <= 0) {
      gameOver = true;
      return DropResult.gameOver;
    }

    final perfect = (activeLeft - prev.left).abs() <= perfectTolerance;
    final double newLeft;
    final double newWidth;
    if (perfect) {
      newWidth = min(initialWidth, prev.width + perfectRegrow);
      // Keep it centered on the block below when regrowing.
      newLeft = (prev.left + prev.right) / 2 - newWidth / 2;
    } else {
      newLeft = overlapLeft;
      newWidth = overlap;
    }

    placed.add(StackBlock(newLeft, newWidth));
    score++;

    // Next active block inherits the new width and re-enters from the left.
    activeWidth = newWidth;
    activeLeft = 0;
    _dir = 1;
    speed = min(maxSpeed, baseSpeed + score * speedIncrement);

    return perfect ? DropResult.perfect : DropResult.stacked;
  }
}
