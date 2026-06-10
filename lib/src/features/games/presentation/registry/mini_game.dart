import 'package:flutter/material.dart';

/// Presentation-side descriptor for a mini game shown on the Games Hub.
///
/// Carries Flutter-specific metadata (icon, accent color, route) so it lives in
/// the presentation layer, not domain. [id] ties it back to the domain scoring
/// records via [GameIds].
@immutable
class MiniGame {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;

  /// Route pushed when the card is tapped.
  final String route;

  /// Whether this game keeps a resumable board / persistent best score. Drives
  /// whether the hub shows a high-score badge.
  final bool tracksHighScore;

  const MiniGame({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.route,
    this.tracksHighScore = true,
  });
}
