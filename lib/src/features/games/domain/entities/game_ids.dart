/// Stable identifiers for each mini game.
///
/// These are the single source of truth for a game's key across the whole
/// feature: the catalog (presentation), the local storage keys (data), and the
/// scoring records (domain) all reference the same constant. When adding a new
/// game, add its id here first.
class GameIds {
  GameIds._();

  static const String game2048 = '2048';
  static const String schulte = 'schulte';
  static const String stackTower = 'stack_tower';
}
