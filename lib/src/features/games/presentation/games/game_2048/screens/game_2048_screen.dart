import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/core/di/injector.dart';
import 'package:lms_mobile_app/src/core/utils/local_storage.dart';

import '../../../../domain/entities/game_ids.dart';
import '../../../../domain/usecases/get_game_score.dart';
import '../../../../domain/usecases/manage_board_state.dart';
import '../../../../domain/usecases/submit_game_result.dart';
import '../../../audio/game_sound_effects.dart';
import '../logic/game_2048_engine.dart';
import '../logic/tile.dart';
import '../widgets/board_2048.dart';

/// 2048. Self-contained: drives the pure [Game2048Engine] from swipe gestures,
/// persists the in-progress board (so the player can resume) and the best score
/// via the games use cases.
class Game2048Screen extends StatefulWidget {
  const Game2048Screen({super.key});

  @override
  State<Game2048Screen> createState() => _Game2048ScreenState();
}

class _Game2048ScreenState extends State<Game2048Screen> {
  static const Color _accent = Color(0xFFEE7B30);
  static const String _gameId = GameIds.game2048;

  // Sound effect assets (drop the files into assets/audio/, see README there).
  static const String _sfxMove = 'audio/sfx_move.mp3';
  static const String _sfxMerge = 'audio/sfx_merge.mp3';
  static const String _sfxGameOver = 'audio/sfx_gameover.mp3';

  final _engine = Game2048Engine();
  final _sl = ServiceLocator().locator;

  late final GetGameScore _getScore = _sl<GetGameScore>();
  late final SubmitGameResult _submitResult = _sl<SubmitGameResult>();
  late final ManageBoardState _board = _sl<ManageBoardState>();

  late final GameSoundEffects _sfx;

  bool _ready = false;
  bool _gameOver = false;
  bool _wonShown = false;
  bool _animating = false;
  bool _soundMuted = false;
  int _best = 0;

  /// Tiles currently rendered. Driven through the two-phase move (slide, then
  /// resolve) so [Board2048] can animate movement and merges.
  List<Tile> _tiles = const [];

  // Accumulated swipe delta for the current drag gesture.
  double _dx = 0;
  double _dy = 0;

  @override
  void initState() {
    super.initState();
    _soundMuted = LocalStorage.isGameSoundMuted();
    _sfx = GameSoundEffects(muted: _soundMuted);
    _sfx.load(const [_sfxMove, _sfxMerge, _sfxGameOver]);
    _bootstrap();
  }

  @override
  void dispose() {
    _sfx.dispose();
    super.dispose();
  }

  Future<void> _toggleSound() async {
    final muted = !_soundMuted;
    setState(() => _soundMuted = muted);
    _sfx.muted = muted;
    await LocalStorage.setGameSoundMuted(muted);
  }

  Future<void> _bootstrap() async {
    final score = await _getScore(_gameId);
    final savedBoard = await _board.load(_gameId);

    if (savedBoard != null && savedBoard.any((v) => v != 0)) {
      final savedScore = await _board.loadScore(_gameId);
      _engine.restore(savedBoard, savedScore);
    } else {
      _engine.newGame();
    }

    if (!mounted) return;
    setState(() {
      _best = score.highScore;
      _tiles = _engine.tiles;
      _ready = true;
    });
  }

  void _onPanStart(DragStartDetails _) {
    _dx = 0;
    _dy = 0;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    _dx += d.delta.dx;
    _dy += d.delta.dy;
  }

  void _onPanEnd(DragEndDetails _) {
    if (_gameOver || _animating) return;
    const threshold = 18.0;
    if (_dx.abs() < threshold && _dy.abs() < threshold) return;

    final MoveDirection dir;
    if (_dx.abs() > _dy.abs()) {
      dir = _dx > 0 ? MoveDirection.right : MoveDirection.left;
    } else {
      dir = _dy > 0 ? MoveDirection.down : MoveDirection.up;
    }
    _handleMove(dir);
  }

  Future<void> _handleMove(MoveDirection dir) async {
    final plan = _engine.planMove(dir);
    if (!plan.moved) return;

    _sfx.play(_sfxMove);

    // Phase 1: slide every tile to its destination (old values preserved).
    setState(() {
      _tiles = plan.slid;
      _animating = true;
    });
    await Future<void>.delayed(kSlide2048Duration);
    if (!mounted) return;

    // Phase 2: resolve merges + spawn (pops play in place).
    _engine.commit(plan);
    setState(() {
      _tiles = _engine.tiles;
      _animating = false;
    });

    if (plan.gained > 0) _sfx.play(_sfxMerge);

    unawaited(
      _board.save(
        gameId: _gameId,
        board: _engine.flatten(),
        score: _engine.score,
      ),
    );

    if (_engine.hasWon && !_wonShown) {
      _wonShown = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Kamu mencapai 2048! Lanjut kejar skor tertinggi.'),
        ),
      );
    }

    if (_engine.isGameOver()) {
      await _finishGame();
    }
  }

  Future<void> _finishGame() async {
    _sfx.play(_sfxGameOver);
    final updated = await _submitResult(gameId: _gameId, score: _engine.score);
    await _board.clear(_gameId);
    if (!mounted) return;
    setState(() {
      _best = updated.highScore;
      _gameOver = true;
    });
  }

  Future<void> _restart() async {
    _engine.newGame();
    _wonShown = false;
    _animating = false;
    await _board.save(
      gameId: _gameId,
      board: _engine.flatten(),
      score: _engine.score,
    );
    if (!mounted) return;
    setState(() {
      _tiles = _engine.tiles;
      _gameOver = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8EF),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF776E65),
        title: const Text(
          '2048',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        actions: [
          IconButton(
            onPressed: _toggleSound,
            tooltip: _soundMuted ? 'Nyalakan suara' : 'Matikan suara',
            icon: Icon(
              _soundMuted
                  ? Icons.volume_off_rounded
                  : Icons.volume_up_rounded,
              color: const Color(0xFF776E65),
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
          ? const Center(
              child: CircularProgressIndicator(color: _accent),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ScoreBox(
                            label: 'SKOR',
                            value: _engine.score,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ScoreBox(label: 'TERBAIK', value: _best),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Geser untuk menggabungkan angka yang sama.',
                      style: TextStyle(
                        color: Color(0xFF8F8678),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: Stack(
                            children: [
                              Board2048(tiles: _tiles),
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
        decoration: BoxDecoration(
          color: const Color(0xFFFAF8EF).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF776E65),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Skor: ${_engine.score}  •  Terbaik: $_best',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF8F8678),
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
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFEEE4DA),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
