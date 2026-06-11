import 'package:flutter/material.dart';
import 'package:lms_mobile_app/src/core/config/constants/app_routes.dart';

import '../../domain/entities/game_ids.dart';
import 'mini_game.dart';

/// The single registry of available mini games. The Games Hub renders one card
/// per entry here.
///
/// To add a new game:
///   1. add its id to [GameIds],
///   2. add its route to [AppRoutes] + register it in the router,
///   3. add one [MiniGame] entry below.
/// Nothing else in the games feature needs to change.
class GameCatalog {
  GameCatalog._();

  static const List<MiniGame> games = [
    MiniGame(
      id: GameIds.game2048,
      title: '2048',
      description: 'Gabungkan angka, kejar skor tertinggi.',
      icon: Icons.grid_4x4_rounded,
      accent: Color(0xFFEE7B30),
      route: AppRoutes.game2048,
    ),
    MiniGame(
      id: GameIds.schulte,
      title: 'Tabel Schulte',
      description: 'Sentuh angka 1–25 secepat mungkin. Latih fokus & kecepatan.',
      icon: Icons.grid_on_rounded,
      accent: Color(0xFF3DA9A3),
      route: AppRoutes.gameSchulte,
    ),
    MiniGame(
      id: GameIds.stackTower,
      title: 'Stack Tower',
      description: 'Ketuk untuk menumpuk balok setinggi mungkin. Jangan meleset!',
      icon: Icons.layers_rounded,
      accent: Color(0xFF6C5CE7),
      route: AppRoutes.gameStackTower,
    ),
  ];
}
