import 'package:flutter/material.dart';

/// Visual style (colors + font) for a single 2048 tile value.
class _TileStyle {
  final Color background;
  final Color text;
  const _TileStyle(this.background, this.text);
}

const Color _darkText = Color(0xFF4E342E);
const Color _lightText = Color(0xFFFFFFFF);

// A colorful spectrum that climbs the hue wheel as the tile value grows:
// cyan → teal → green → lime → amber → orange → pink → purple → indigo.
const Map<int, _TileStyle> _styles = {
  2: _TileStyle(Color(0xFF26C6DA), _darkText), // cyan
  4: _TileStyle(Color(0xFF26A69A), _lightText), // teal
  8: _TileStyle(Color(0xFF66BB6A), _lightText), // green
  16: _TileStyle(Color(0xFF9CCC65), _darkText), // light green
  32: _TileStyle(Color(0xFFFFCA28), _darkText), // amber
  64: _TileStyle(Color(0xFFFFA726), _lightText), // orange
  128: _TileStyle(Color(0xFFFF7043), _lightText), // deep orange
  256: _TileStyle(Color(0xFFEC407A), _lightText), // pink
  512: _TileStyle(Color(0xFFAB47BC), _lightText), // purple
  1024: _TileStyle(Color(0xFF7E57C2), _lightText), // deep purple
  2048: _TileStyle(Color(0xFF5C6BC0), _lightText), // indigo
};

// Beyond 2048: a vivid magenta to make the rare high tiles feel rewarding.
const _TileStyle _superStyle = _TileStyle(Color(0xFFD81B60), _lightText);

/// A single (non-empty) board tile. Sliding between cells is handled by the
/// parent's [AnimatedPositioned]; this widget owns the "pop" animation that
/// plays when the tile first appears (a spawn) and again whenever its value
/// changes (a merge). Driven by lifecycle (initState / didUpdateWidget) rather
/// than widget keys, so it stays correct as the same tile element persists
/// across moves.
class Tile2048 extends StatefulWidget {
  final int value;
  final double size;

  const Tile2048({super.key, required this.value, required this.size});

  @override
  State<Tile2048> createState() => _Tile2048State();
}

class _Tile2048State extends State<Tile2048>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _scale = Tween<double>(begin: 0.55, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward(); // pop in on first appearance (spawn / load)
  }

  @override
  void didUpdateWidget(covariant Tile2048 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Value changed → this tile is the survivor of a merge: pop again.
    if (oldWidget.value != widget.value) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = _styles[widget.value] ?? _superStyle;

    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: widget.size,
        height: widget.size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              '${widget.value}',
              style: TextStyle(
                color: style.text,
                fontWeight: FontWeight.w900,
                fontSize: widget.size * 0.42,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
