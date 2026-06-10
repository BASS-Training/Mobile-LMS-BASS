/// A single 2048 tile with a stable [id] so the UI can animate it sliding from
/// one cell to another across moves. Immutable — the engine produces new tiles
/// each step, which keeps widget keys stable and predictable.
class Tile {
  final int id;
  final int value;
  final int row;
  final int col;

  /// True only for a freshly spawned tile (drives the spawn pop animation).
  final bool isNew;

  /// True for the surviving tile of a merge this step (drives the merge pop).
  final bool merged;

  const Tile({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.isNew = false,
    this.merged = false,
  });

  Tile copyWith({int? value, int? row, int? col, bool? isNew, bool? merged}) {
    return Tile(
      id: id,
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      isNew: isNew ?? this.isNew,
      merged: merged ?? this.merged,
    );
  }
}

/// The outcome of a planned move, split into two animation phases:
/// 1. [slid] — every pre-existing tile moved to its destination cell, still
///    showing its OLD value (merged pairs stack on the same cell).
/// 2. [finalTiles] — the resolved board: merged tiles doubled, absorbed tiles
///    gone, and the newly spawned tile added.
/// The screen renders [slid] first (the slide), then [finalTiles] (the pop).
class MovePlan {
  final bool moved;
  final int gained;
  final List<Tile> slid;
  final List<Tile> finalTiles;

  const MovePlan({
    required this.moved,
    required this.gained,
    required this.slid,
    required this.finalTiles,
  });
}
