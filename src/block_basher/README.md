# Block Basher — unpublished prototype

Original breakout-inspired game for the 466×466 round Sweetcorn display. This is
source and original generated artwork only: no signed pack, catalogue change,
firmware integration, publication, console installation or hardware verification.

## Play

- The bricks are three concentric rings in the middle of the field (6, 8 and 10
  arc bricks at radii 66, 96 and 126) around the theme's centrepiece. The paddle is
  a 64-degree bead arc at radius 196, just inside the field's stone ring, and runs
  the whole 360 degrees.
- Tap anywhere (away from the small mode button at about eight o'clock) to launch.
  A finger anywhere on the field puts the paddle at the finger's angle, so the
  finger can sit well away from the ball. Within 40 px of the centre it does nothing.
- Before launch, tap the 44 px mode button to choose tilt: the console is a wheel,
  and the paddle sits where gravity points (`sys.tilt` x,y; below 150 milli-g the
  last angle is kept, so a console flat on a table still steers by tipping its
  edge). A missing or dropped sensor falls back to touch. Mode is locked during play.
- Break 24 bricks (10 points each), with three lives. The ball bounces off the
  bricks (radial reflection), the centrepiece and the paddle; past radius 215 it is
  lost and a fresh tap serves the next one from the paddle. Paddle-edge hits aim
  the return up to 30 degrees. Clear the rings or run out of lives for in-game
  results; tap to reset, then tap to launch. Best score uses the host best store.

## Implementation and integration

`main.lua` is standalone sandbox-compatible Lua; `pack.json` has the <=8-character
ID `blockbas`. Engine 6 game-owned bundle conventions are declared. `art/<theme>`
contains background, ball, centrepiece, two 44 px mode buttons and `_tile.png` for
outdoors, space, dinosaurs, unicorns and manga, built from the shipped theme sets
by `tools/newgames/review_prototypes.py build`: the background is the theme's
`bg_soil` page (Snake's stone/asteroid/lava/cloud ring, black outside the glass),
the ball and centrepiece are the design pass's `bb_ball` (acorn, star, egg, pink
ball, temari) and `bb_centre` (sun, planet, volcano, rainbow cloud, lantern), the
rings are the theme's `tilt_wall` colour, accent2 gold and ok green, the paddle
beads the wall colour, and the mode button a palette disc with the theme's
`rb_tap` hand. `make_assets.py` only checks the files exist.

For parent integration, use the existing engine-6 **game-owned bundle** pipeline
with `main.lua` and these per-theme assets. The manifest's `theme_art`, `tile` and
`bundle_kind` fields document the candidate; they do not add a new build command
to shared gpk.py. Do not build this as a legacy rules-only pack: the shared themes
have no Block Basher art. Signing/publication remains outside this prototype.

Only supported host calls are used: image/src/pos/hide/box/arc/text plus
sys.theme/tilt/active/score/best/set_best/beep. No save/load dependency or dynamic
loading. The script returns its state table for test inspection; firmware ignores
that return and uses normal global init/tick entry points. No test hooks are
installed in globals. Exactly 37 drawing objects are allocated once (field,
centrepiece, 24 brick arcs, 9 paddle beads, ball, mode button); restarts reuse
them (host object IDs are lifetime-limited to 512). The host cannot change an
arc's angles after creation, which is why the moving paddle is nine 20 px discs
repositioned each tick and the bricks are fixed arcs that are hidden when popped.
Selected-theme pixel payload is 460,576 bytes excluding tile.

Physics is original: fixed 240 Hz steps, maximum 100 ms catch-up / 24 steps,
polar contacts (paddle arc met from inside while moving outward, centrepiece disc,
brick bands with angular segments widened by the ball's angular radius), radial
reflection with depenetration, one contact per substep, 170 to 260 px/s. Long
stalls deliberately slow simulation rather than teleport through objects. Backward
time advances nothing.

## Local checks

From the workspace:

```sh
bash projects/esp32-s3-amoled/game-library/src/block_basher/tests/run.sh
```

This compiles the repository's actual Lua (32-bit integers / single-precision
floats) under AddressSanitizer + UndefinedBehaviorSanitizer; the C runner only
opens the same base/math/table/string libraries as firmware. A strict mock checks
host integer argument types, object existence/count and asset names. Tests cover
launch, touch steering round the full circle, paddle centre and edge returns, a
lost ball, centrepiece and brick inner/outer/side contacts, repeat scoring, lives,
release gating, victory, persistent best, restart, tilt as a wheel (settles where
gravity points, dead band, upside down), missing/dropout sensor, clock stalls,
frame-rate equivalence, 20,000 simulated frames following the ball round the ring
and 1,000 restarts **in each theme**. Asset checks validate all 30 PNGs, manifest,
theme coverage, the round ring layout and art budget. Scratch binaries
stay under `$TMPDIR` (fallback `~/.cache/openclaw-tmp`).

## Still unverified

These are real Lua tests against a mocked graphics/system boundary, **not** a full
LVGL/signed-pack host integration test. Round layout, colour contrast, text legibility,
touch sampling, tilt feel/calibration on glass, audio queues, frame latency, PSRAM
headroom and physical usability still need the console. Asset generation and
budgets are checked; actual bundle assembly/loading remains parent integration.
