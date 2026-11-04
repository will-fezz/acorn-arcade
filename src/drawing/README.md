# Drawing — local prototype, not released

Freehand pixel-paint for the round 466px Sweetcorn screen, using the real engine-6
Lua graphics API and game-owned art. Finger or **capacitive** stylus; no pressure,
palm rejection or active-pen protocol is claimed.

- A round white paper of radius 186 px fills the glass; internally 377 cells of
  16 px whose centres lie within 176 px of the centre (a 23×23 grid with the
  corners missing). That is 2.6 times the drawable area of the first 288×216
  rectangle, at 16 px rather than 12 px cells: the host's 512 lifetime object cap
  sets the trade (a 12 px disc would need about 750 cells).
- Tools hug the rim at radius 206: six 36 px colour discs across the top (18
  degrees apart), and across the bottom three brush sizes (16/48/80 px
  footprints), the eraser and Clear. Hit radius is 30 px; neighbouring targets are
  64 px apart. Clear opens a Keep/Clear card requiring a new contact.
- Bresenham interpolation fills skipped samples; pen-up and leaving the paper
  break strokes. Dragging from a rim tool cannot paint or activate another tool.
- All 377 cell images are reused indefinitely. Erasing changes cells to white;
  it does not hide an accumulated stack of strokes. Total graphics handles: 393,
  below the host's lifetime 512-handle cap. No object allocation in tick.
- Outdoors, Space, Dinosaurs, Unicorns and Manga retain their palette around the
  neutral canvas. Unknown theme keys fall back to Outdoors. Theme artwork and
  selector tiles are game-owned: no shared theme edits.

## Deliberate limitations

This is **coarse pixel freehand**, not a smooth/high-resolution sketch pad. The
host exposes images and fixed lines, but no mutable bitmap canvas or line-point
update. A full-resolution unrestricted stroke stack would exhaust its lifetime
512-object limit; deleting objects does not reclaim IDs. A future firmware
canvas API (one mutable bitmap object) would allow smooth unlimited freehand on
the whole glass without this compromise; until then the 16 px round grid is the
largest paper the object budget allows.

**No save.** The page says "Drawing is not saved" until the first touch, and the
Clear card repeats it. Closing the game/restarting
loses the picture. Engine 5+ does expose sys.save/load (256 printable bytes per
key), but sys.save discards settings_set_str's result and offers no durable-write
acknowledgement or transaction. A compact encoding is conceivable; this prototype
does not claim reliable picture persistence, create NVS keys, or repurpose scores.

No signing, publishing, catalogue edit, firmware edit or console installation.
Real touch latency, 432-cell rendering performance, memory fragmentation and
capacitive stylus behaviour are **hardware unverified**. Tests use the vendored
Lua VM with API mocks, not the actual LVGL/display/input implementation.

## Local checks

From workspace root:

```
projects/esp32-s3-amoled/game-library/src/drawing/tests/run.sh
projects/esp32-s3-amoled/venv/bin/python projects/esp32-s3-amoled/game-library/src/drawing/bundle_items.py
```

The test runner compiles vendored Lua into a temporary directory and removes it
on exit. Tests cover six theme cases, the 377-cell round paper, fast sampled strokes, dot
taps, all widths, colour selection, erasing, clipping at the paper edge,
pen-up/outside discontinuities, rim-tool drag isolation, confirmation/cancel/held-
contact safety, the not-saved note, 1000-contact sessions, repeated clear, rim
targets inside the safe circle and 56 px apart, and fixed object budgets. Assets are built from the shipped
theme sets by `tools/newgames/review_prototypes.py build` (background = the theme's
`bg_picnic` page, toolbar/note/confirm card drawn from the theme palette in
Sniglet); `make_assets.py` only checks they exist.

`bundle_items.items()` returns unsigned engine-6 kind-3 entries with all five
themes and tiles for later authorized integration. Standard legacy `gpk.py build`
is not the correct five-theme bundle path. No .gpk is produced here.
