import 'package:flutter/material.dart';

/// Visual style (colors + font) for a single 2048 tile value.
class _TileStyle {
  final Color background;
  final Color text;
  const _TileStyle(this.background, this.text);
}

const Color _darkText = Color(0xFF776E65);
const Color _lightText = Color(0xFFF9F6F2);

const Map<int, _TileStyle> _styles = {
  2: _TileStyle(Color(0xFFEEE4DA), _darkText),
  4: _TileStyle(Color(0xFFEDE0C8), _darkText),
  8: _TileStyle(Color(0xFFF2B179), _lightText),
  16: _TileStyle(Color(0xFFF59563), _lightText),
  32: _TileStyle(Color(0xFFF67C5F), _lightText),
  64: _TileStyle(Color(0xFFF65E3B), _lightText),
  128: _TileStyle(Color(0xFFEDCF72), _lightText),
  256: _TileStyle(Color(0xFFEDCC61), _lightText),
  512: _TileStyle(Color(0xFFEDC850), _lightText),
  1024: _TileStyle(Color(0xFFEDC53F), _lightText),
  2048: _TileStyle(Color(0xFFEDC22E), _lightText),
};

const _TileStyle _superStyle = _TileStyle(Color(0xFF3C3A32), _lightText);

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
