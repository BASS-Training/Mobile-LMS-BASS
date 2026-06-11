import 'package:flutter/material.dart';

import '../logic/game_2048_engine.dart';
import '../logic/tile.dart';
import 'tile_2048.dart';

/// How long a tile takes to slide between cells. The game screen waits this
/// long after starting a slide before resolving merges/spawns.
const Duration kSlide2048Duration = Duration(milliseconds: 130);

/// Renders the 4x4 board: a static grid of empty slots with the live [tiles]
/// positioned on top via [AnimatedPositioned], so value/position changes
/// animate smoothly. Sizes itself to a square from the available width.
class Board2048 extends StatelessWidget {
  final List<Tile> tiles;

  const Board2048({super.key, required this.tiles});

  static const double _gap = 10;
  static const double _padding = 10;
  static const Color _boardBg = Color(0xFFBBADA0);
  static const Color _emptyCell = Color(0xFFCDC1B4);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth;
        const n = Game2048Engine.size;
        final tileSize = (boardSize - _padding * 2 - _gap * (n - 1)) / n;

        double offset(int index) => _padding + index * (tileSize + _gap);

        final cellRadius = tileSize * 0.16;

        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: Stack(
            children: [
              // Board background with depth.
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFC3B5A8), _boardBg],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),
              // Static empty slots (slightly inset look).
              for (var r = 0; r < n; r++)
                for (var c = 0; c < n; c++)
                  Positioned(
                    left: offset(c),
                    top: offset(r),
                    width: tileSize,
                    height: tileSize,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _emptyCell.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(cellRadius),
                      ),
                    ),
                  ),
              // Live tiles (keyed by id so they animate as they move).
              for (final tile in tiles)
                AnimatedPositioned(
                  key: ValueKey(tile.id),
                  duration: kSlide2048Duration,
                  curve: Curves.easeInOut,
                  left: offset(tile.col),
                  top: offset(tile.row),
                  width: tileSize,
                  height: tileSize,
                  child: Tile2048(value: tile.value, size: tileSize),
                ),
            ],
          ),
        );
      },
    );
  }
}
