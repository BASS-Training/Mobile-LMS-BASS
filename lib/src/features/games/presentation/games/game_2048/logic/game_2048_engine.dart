import 'dart:math';

import 'tile.dart';

enum MoveDirection { up, down, left, right }

/// Pure 2048 game logic — no Flutter, no persistence. Holds a list of [Tile]s
/// (each with a stable id so the UI can animate slides) and the running
/// [score]. Kept framework-free so it can be unit tested in isolation.
class Game2048Engine {
  static const int size = 4;
  static const int winningTile = 2048;

  List<Tile> tiles = const [];
  int score = 0;

  int _nextId = 0;
  final Random _rng;

  Game2048Engine({Random? rng}) : _rng = rng ?? Random();

  /// Starts a fresh game: empty board with two spawned tiles.
  void newGame() {
    tiles = const [];
    score = 0;
    _nextId = 0;
    final a = _makeSpawn(tiles);
    if (a != null) tiles = [...tiles, a];
    final b = _makeSpawn(tiles);
    if (b != null) tiles = [...tiles, b];
  }

  /// Restores a game from a flattened (row-major) board and its score.
  /// Falls back to a new game if the data is the wrong shape.
  void restore(List<int> flat, int savedScore) {
    if (flat.length != size * size) {
      newGame();
      return;
    }
    final restored = <Tile>[];
    var id = 0;
    for (var i = 0; i < flat.length; i++) {
      if (flat[i] != 0) {
        restored.add(
          Tile(id: id++, value: flat[i], row: i ~/ size, col: i % size),
        );
      }
    }
    tiles = restored;
    score = savedScore;
    _nextId = id;
  }

  /// Row-major flattening for persistence.
  List<int> flatten() {
    final grid = List.filled(size * size, 0);
    for (final t in tiles) {
      grid[t.row * size + t.col] = t.value;
    }
    return grid;
  }

  int get maxTile {
    var m = 0;
    for (final t in tiles) {
      if (t.value > m) m = t.value;
    }
    return m;
  }

  bool get hasWon => maxTile >= winningTile;

  /// No empty cells and no two equal neighbours left to merge.
  bool isGameOver() {
    if (tiles.length < size * size) return false;
    final grid = _grid();
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final v = grid[r][c]?.value ?? 0;
        if (c + 1 < size && (grid[r][c + 1]?.value ?? 0) == v) return false;
        if (r + 1 < size && (grid[r + 1][c]?.value ?? 0) == v) return false;
      }
    }
    return true;
  }

  /// Plans a move without mutating engine state. Returns the two-phase
  /// animation plan; call [commit] to apply it once the slide has played.
  MovePlan planMove(MoveDirection dir) {
    final grid = _grid();
    var moved = false;
    var gained = 0;
    final slid = <Tile>[];
    final finalTiles = <Tile>[];

    for (var i = 0; i < size; i++) {
      // Tiles along this line, read from the destination edge outward.
      final line = <Tile>[];
      for (var p = 0; p < size; p++) {
        final cell = _cell(i, p, dir);
        final t = grid[cell[0]][cell[1]];
        if (t != null) line.add(t);
      }

      var slot = 0;
      var k = 0;
      while (k < line.length) {
        final dest = _cell(i, slot, dir);
        final a = line[k];
        final canMerge = k + 1 < line.length && line[k + 1].value == a.value;

        if (canMerge) {
          final b = line[k + 1];
          // Both tiles slide onto the destination cell (old value preserved).
          slid.add(Tile(id: a.id, value: a.value, row: dest[0], col: dest[1]));
          slid.add(Tile(id: b.id, value: b.value, row: dest[0], col: dest[1]));
          // Resolved: one doubled tile, reusing a's id so it pops in place.
          finalTiles.add(
            Tile(
              id: a.id,
              value: a.value * 2,
              row: dest[0],
              col: dest[1],
              merged: true,
            ),
          );
          gained += a.value * 2;
          moved = true; // a merge always changes the board
          k += 2;
        } else {
          slid.add(Tile(id: a.id, value: a.value, row: dest[0], col: dest[1]));
          finalTiles.add(
            Tile(id: a.id, value: a.value, row: dest[0], col: dest[1]),
          );
          if (a.row != dest[0] || a.col != dest[1]) moved = true;
          k += 1;
        }
        slot++;
      }
    }

    if (!moved) {
      return MovePlan(moved: false, gained: 0, slid: tiles, finalTiles: tiles);
    }

    final spawn = _makeSpawn(finalTiles);
    return MovePlan(
      moved: true,
      gained: gained,
      slid: slid,
      finalTiles: spawn != null ? [...finalTiles, spawn] : finalTiles,
    );
  }

  /// Applies a planned move's resolved state.
  void commit(MovePlan plan) {
    tiles = plan.finalTiles;
    score += plan.gained;
  }

  List<List<Tile?>> _grid() {
    final grid = List.generate(size, (_) => List<Tile?>.filled(size, null));
    for (final t in tiles) {
      grid[t.row][t.col] = t;
    }
    return grid;
  }

  /// (row, col) of position [p] along line [i] for [dir], where p = 0 is the
  /// destination edge the tiles move toward.
  List<int> _cell(int i, int p, MoveDirection dir) {
    switch (dir) {
      case MoveDirection.left:
        return [i, p];
      case MoveDirection.right:
        return [i, size - 1 - p];
      case MoveDirection.up:
        return [p, i];
      case MoveDirection.down:
        return [size - 1 - p, i];
    }
  }

  Tile? _makeSpawn(List<Tile> occupied) {
    final taken = {for (final t in occupied) t.row * size + t.col};
    final empties = [
      for (var i = 0; i < size * size; i++)
        if (!taken.contains(i)) i,
    ];
    if (empties.isEmpty) return null;
    final cell = empties[_rng.nextInt(empties.length)];
    // Classic 2048 odds: 90% a 2, 10% a 4.
    return Tile(
      id: _nextId++,
      value: _rng.nextInt(10) == 0 ? 4 : 2,
      row: cell ~/ size,
      col: cell % size,
      isNew: true,
    );
  }
}
