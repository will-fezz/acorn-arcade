# Letter Tracing — morning-review candidate

**Status:** playable Lua source with all 52 print letters, five-theme artwork and
rule tests. **Not signed, published, installed or tested on the console.** Pack ID
`tracing` fits the existing eight-character save namespace. Source folder is
`letter-tracing`; the shared library catalogue has not been changed.

## Play

Tap the introduction to begin. Follow the gold dot along the wide pale letter;
the traced portion turns the theme's accent colour. Each pen stroke must be
followed in order; lift between strokes. You can lift midway and resume at the
dot without losing progress. No clock, losing lives or negative sounds.

- Top letter / small Aa: switch uppercase and lowercase.
- Bottom left/right arrows: previous/next letter, wrapping A–Z or a–z.
- Bottom circular arrow: repeat this letter.
- A star beside the letter marks completion; the page stays for the child to
  admire/repeat rather than advancing unexpectedly.
- Last selected letter and case are retained in `sys.save('pick', ...)`.
- Completed-letter count is session activity, not a misleading accuracy grade.

These are original simplified monoline print forms (including single-storey a
and g), **not a claim of a particular school's handwriting scheme**. The user
requested print first and cursive later; no cursive mode is present. Case choice
is directly in the game for this prototype; parent-app handwriting controls are
not implemented here.

## Theme/host compatibility

Uses existing engine-6 `gfx` primitives, `sys.save/load/score/beep/theme`, and a
single bundled background image. `art/<theme>/paper.png` and `tile.png` exist for
Outdoors, Space, Dinosaurs, Unicorns and Manga. Tiles are original Aa typography
inside each theme's circular palette/ring, not new AI mascot art. The immutable
letter guides work in every theme. Art is built from the shipped theme sets by
`tools/newgames/review_prototypes.py build` (paper = the theme's `bg_pond` field, the same page Numbers uses, with white guide dots at 80 % so the letter reads on it,
mascot = the theme's `rb_idle` at 90 px, tile cut from the same field); `create_art.py` regenerates the palette
table from the five current source themes.

The host exposes `ui/names`, **not** `ui/palette`, through `sys.theme`. Therefore a
local palette table is keyed by the existing unique `tilt_wall` value in each
shipped theme; unknown future themes use the Outdoors fallback. No shared theme
or firmware changes are required for the current five themes. Future API work
could expose palette values explicitly; it is not required to play this build.

Important: `gfx.del` does not reclaim the host's lifetime object-handle budget.
This game allocates exactly **241 handles once** (224 pooled guide/ink dots plus
background, controls and marker), then only hides/moves them. Repeating letters
never allocates more objects. Maximum current glyph length is 104 checkpoints;
112 are reserved per pool, safely below the 512-handle limit.

## Reproduce

From the workspace:

```sh
python3 projects/esp32-s3-amoled/game-library/src/letter-tracing/create_source.py
python3 projects/esp32-s3-amoled/game-library/src/letter-tracing/create_art.py
projects/esp32-s3-amoled/game-library/src/letter-tracing/test.sh
python3 projects/esp32-s3-amoled/game-library/src/letter-tracing/validate_candidate.py
python3 projects/esp32-s3-amoled/game-library/src/letter-tracing/render_preview.py
```

Requires Python/Pillow, gcc and the repository's bundled Lua C sources. Assets
use the system DejaVu Sans font. The tests compile that exact Lua interpreter,
with strict host argument/handle stubs; these are **not** real-LVGL or hardware
integration tests. Preview PNGs under `state/sweetcorn-new-games/letter-tracing`
render the recorded test primitives with Pillow, **not device screenshots**.

The candidate validator writes `bundle-inputs.json`: exact engine-6 kind-3 bundle
inputs for integration. Use the established bundle writer to assemble/sign only
when authorized. `pack.json` is source metadata, **not permission to call the
legacy rules-only builder**; UI-only themes require the self-contained bundle.
No signing keys were read and no `.gpk` was emitted. All shared files remain
untouched.

## Review gates

Before release: integrate unsigned inputs into the normal bundle build and real
LVGL host harness; inspect glyphs/contrast/control hit areas at device scale;
check touch sampling and frame rate, physical stylus response, memory on real
hardware and suspend/exit behaviour. Have Will approve the letter forms and
handwriting stroke sequence. Consider bespoke painted mascot tiles as a later
art pass. Publication and console installation remain separate authorized steps.

2026-11-04: Removed the decorative character from the tracing screen in every theme after it overlapped the title/instructions. The Numbers-matching pond background is retained.

Real LVGL integration also shortened the intro subtitle to one line: the fixed host title/subtitle anchors overlap with three lines. Case toggle and lift-between-strokes behaviour are unchanged.
