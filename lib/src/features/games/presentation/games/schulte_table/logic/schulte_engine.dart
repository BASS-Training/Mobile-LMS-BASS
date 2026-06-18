import 'dart:math';

/// Outcome of tapping a cell.
enum TapResult {
  /// The tapped number was the one we were looking for.
  correct,

  /// The tapped number was not the current target.
  wrong,

  /// The tapped number was the last one — the board is solved.
  finished,
}

/// Pure Schulte-table logic — no Flutter, no persistence, no timing.
///
/// Holds a shuffled grid of the numbers `1..size*size` and tracks which number
/// the player must tap next. The screen owns the clock and scoring; this engine
/// only answers "was that tap right, and are we done?". Framework-free so it can
/// be unit tested in isolation.
class SchulteEngine {
  final int size;
  final Random _rng;

  /// Row-major cell values; `cells[i]` is the number drawn in cell `i`.
  List<int> cells = const [];

  /// The number the player must tap next (1-based). Equals `count + 1` once the
  /// board is solved.
  int nextTarget = 1;

  SchulteEngine({this.size = 5, Random? rng}) : _rng = rng ?? Random();

  int get count => size * size;

  bool get isFinished => nextTarget > count;

  /// How many numbers have been found so far (0..count).
  int get found => nextTarget - 1;

  /// Starts a fresh round: reshuffles the grid and resets the target to 1.
  void newGame() {
    cells = [for (var i = 1; i <= count; i++) i]..shuffle(_rng);
    nextTarget = 1;
  }

  /// Registers a tap on [value]. Advances the target on a correct tap and
  /// reports whether that tap solved the board.
  TapResult tap(int value) {
    if (isFinished || value != nextTarget) return TapResult.wrong;
    nextTarget++;
    return isFinished ? TapResult.finished : TapResult.correct;
  }
}
