# Dots and Boxes — unpublished prototype

Three board sizes on the 466×466 round touchscreen, chosen with the three discs under the mode pills: **Small** 2×2 boxes (9 dots, 12 lines, 96 px pitch), **Medium** 3×3 boxes (16 dots, 24 lines, 72 px pitch) and **Large** 4×4 boxes (25 dots, 40 lines, 56 px pitch). The last size is remembered with `sys.save('size')` when the host has it. Pick **Easy computer** (you are 1) or **Two players**. Tap near an unclaimed line. Closing a box scores one point and keeps your turn; a shared edge can claim two boxes. Highest score after all the boxes wins, draws included. **Again** resets immediately; **Mode** returns to the picker. The console's normal exit remains available.

Geometry: Small and Medium are centred at (233, 247), Large at (233, 249) between the status strip and the footer; the large board's dots run from 121 to 345 across and 137 to 361 down, so 4×4 boxes fits the glass with the same header and footer. A tap goes to the **nearest line midpoint** if it is within the hit radius (30 px on Small and Medium, 22 px on Large: half the pitch less 6, so dots and box centres are always dead). On Large that radius is below the 28 px a four-year-old's finger wants; Large is there for the grown-ups and the six-year-old she will be, Small is the default. Lines and stickers are the same images scaled by the host (`gfx.scale` 192 / 176 on Large). Footer taps (y ≥ 376) take precedence over the bottom row's lower half.

The easy computer takes an immediately available box, otherwise chooses a random legal edge; no chain search, on any size. It waits 650 ms per move, including extra turns. Contacts during that wait are not queued. One physical contact makes at most one move. Menu targets 270×72, size discs 64 px, footer targets 112×56. All target corners fit the round screen.

Distinct player claim stickers supplement theme colours. Score is the two numbers at the top, in the same order; the play log records player 1's box count (not wins or a persistent high score). Static status/menu/button text is rasterized Sniglet because the current host has no freely positioned label API. Art per theme is built from the shipped theme sets by `tools/newgames/review_prototypes.py build`: the background is the theme's `bg_garden` page (Pop-Up Tap's field), the claim stickers are the design pass's `bx_a`/`bx_b`, the rival on the menu is the theme's `mn_pip`, player lines are the palette's accent2/accent, and the pills, dots and status strips are drawn from the theme palette in Sniglet with the HUD shadow; no shared theme edits.

Requires engine 6 game-owned bundle support. `pack.json` is an **unpublished-candidate** manifest, not a signed package. No catalogue entry, firmware edits, publication, signing or console install has been performed.

## Reproduce

From the project root:

```sh
venv/bin/python -I tools/newgames/review_prototypes.py build --boxes-only   # only Squares; leaves Letter Tracing untouched
bash game-library/src/boxes/tests/run.sh
venv/bin/python -I tools/newgames/review_prototypes.py record --boxes-only
venv/bin/python -I tools/newgames/review_prototypes.py preview --boxes-only
venv/bin/python -I tools/newgames/review_prototypes.py contact --boxes-only
```

Tests compile the actual vendored console Lua (32-bit numbers) with ASan/UBSan. Rendering is a strict object-recording mock of the exercised host API, not LVGL/display emulation. Objects are allocated once for the largest board (65: field, header, board, menu, footer, 40 lines, 16 stickers, size halo, 3 size discs) and reused on every size. The rules test runs 1,000 randomised two-player games and 360 computer games across the three sizes against an independent box-ownership checker, plus dead zones, nearest-edge near misses, hidden surplus objects, size persistence and timer wrap. Asset checks decode every manifest image, validate bundle-name length and unpacked per-theme budget, and verify all three board geometries inside the round glass. The picker discs and halo are hidden during play and restored on Mode. Saved-size restoration and invalid-value fallback are checked in fresh game instances. Only the size is saved; returning to the game starts a fresh round.

**Unverified:** real panel appearance, touch accuracy/comfort (especially the 22 px hit radius on Large), audio and performance, complete signed bundle loading on firmware.

Preview PNGs are written under `${TMPDIR:-$HOME/.cache/openclaw-tmp}/sweetcorn-design-review/png/after/boxes/` (all five themes, menu, each board size and end screen). They are local recording-mock composites, not physical-device captures.

Verified 4 November 2026: ASan/UBSan rules suite passed (1,000 two-player and 360 computer rounds); five-theme image/budget/geometry checks passed. Regenerated and visually inspected the 25-state contact sheet. Shared previews: `/home/will/share/Eric-Agent/Sweetcorn/design-review/squares-grid-sizes/`, contact sheet `contact-grid-sizes.png`. The scoped commands do not regenerate Letter Tracing or overwrite the six-game overview. Nothing installed, signed, deployed or published.

2026-11-04 integration: replaced three full-grid image allocations with 25 reusable 24px dot sprites (89 total handles); all three grid sizes retained. This meets the engine-6 bundle limit of 1300 KiB per theme, not the legacy-theme 2 MiB limit.
