# Tic-tac-toe — unpublished candidate

Game ID **`tictac`** (six characters); directory name is intentionally descriptive.
For Sweetcorn's 466×466 round touchscreen and engine **6** game-owned bundles.
No firmware or shared theme changes are required by this implementation.

## Play

- Choose **Easy computer** (you are X) or **Two players** (pass the console; X starts).
- Tap an empty square. X and O have different shapes as well as theme colours.
- The computer chooses a random legal move after 650 ms: deliberately beatable, not minimax.
- Three in a row wins; a full board without a line draws. The result stays visible.
- **Again** clears the board in the current mode. **Mode** returns to the chooser.
- The console's normal exit gesture is untouched.
- No persistent save or competitive high score. Activity score counts completed rounds this launch.

The large 76×76 square targets are inset into an 84-pixel grid, within the circular
screen. Narrow separators reject taps rather than guessing. Holding/dragging a
finger cannot place another mark; computer-turn taps are never queued. A new
round or mode change cancels a pending computer move. All 31 drawing objects are
allocated once and reused: no eventual host object-slot exhaustion.

## Assets and theme support

`art/{outdoors,space,dinosaurs,unicorns,manga}` contains each game's own complete
image set and a 240×240 transparent selector tile, built from the shipped theme
sets: the background is the theme's `bg_lawn` page (the tilt maze's field), the
two tokens (`cross`/`ring`, names kept for the hit tests) are the design pass's
`tt_a`/`tt_b` (ladybird v bee, rocket v alien, T-rex v stego, heart v star, daruma v
onigiri), the rival on the menu is the theme's `mn_pip`, and the pills, grid and
status strips are drawn from the theme palette in Sniglet with the HUD shadow.
`tools/newgames/review_prototypes.py build` regenerates them; `make_art.py` only
checks they exist.
The Lua uses only real host calls (`gfx.image/src/pos/hide/line/text` and
`sys.random/beep/score/active`); no placed-label API, new firmware or fake globals.

## Packaging (parent/release owner)

`pack.json` declares the gameplay image names and the `tictac` ID. `bundle_items.py`
exports `items()` in the existing `gpk.write_pack` tuple format, including all five
skins and `_tile` entries. Its CLI **validates only**; it does not sign or output a
`.gpk`. The authorized release path must use kind 3, engine minimum 6, version 1,
and deflation. Do not use legacy `gpk.py rules` alone: shell-only themes do not have
this new game's assets. Do not add the candidate to the live catalogue incidentally.

Five-theme payload: 72 entries; 1,075,304 decoded gameplay bytes per selected theme
(under 1,331,200-byte budget); tile 172,800 decoded bytes. Compressed entry data is
about 294 KB before TOC/alignment/dedup. Release signing/format-parser verification,
catalogue integration, install/download behaviour and real console play remain
parent-owned follow-up work after review, not claims of this candidate.

## Verification

From any directory:

```sh
./tests/run.sh
python3 tests/art_check.py
python3 bundle_items.py
```

The rules test compiles the console's vendored **32-bit Lua** with AddressSanitizer
and UndefinedBehaviorSanitizer. Its restricted game environment stubs the real
host API's integer/argument/object rules. It verifies all eight winning lines,
O wins, draws, occupied/outside/separator taps, held touches, AI legality/delay,
timer wrap, mode/restart cancellation and 250 repeated computer games. Last run:
**2,796 checks passed; 31 objects; <4,000 VM instructions per call** at 1,000-step
measurement granularity (host budget is 2,000,000). No sanitizer findings.

`art_check.py` validates all five skin assets/budgets and composites captured game
states to `$TMPDIR/sweetcorn-tictac-tests/contact-sheet.png` (default cache path if
TMPDIR is unset). These are **design previews, not real LVGL or console screenshots**.
The contact sheet was visually checked: readable labels, no overlapping controls,
all game cells/footer controls inside the round display.

Not yet verified: real LVGL rendering, on-console finger feel, real sound timing,
actual firmware RAM/flash use after packing, and phone-app display of the new ID.
