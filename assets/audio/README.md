# Audio assets

Sound effects for the mini games live here.

## 2048 sound effects

Put these short sound files in this folder (names must match exactly):

| File | Plays when |
|------|------------|
| `sfx_move.mp3`     | a valid swipe/move |
| `sfx_merge.mp3`    | two tiles merge |
| `sfx_gameover.mp3` | the game ends |

- Referenced in code as `AssetSource('audio/sfx_move.mp3')` etc.
  (audioplayers prepends `assets/` automatically).
- Keep them **short** (< ~1 s) and small. `.mp3`, `.wav`, or `.ogg` all work;
  short `.wav`/`.ogg` tend to have the lowest latency for SFX.
- If a file is missing the game still works — that effect is just silent
  (loading is wrapped in try/catch in `GameSoundEffects`).

Use royalty-free / properly licensed sounds (e.g. Pixabay, freesound.org).
