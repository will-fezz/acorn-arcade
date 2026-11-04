# Numbers — candidate for morning review

A touch-first Lua game for Matilda: **Count**, **Trace 0–10**, and **More / Less**.
Not published, signed or installed. Uses the current host API (engine 6 bundle).

## Play

- Main screen: left **3** button starts Count; middle dotted **2** starts Trace;
  right dot-groups button starts Compare. Labels above follow the same order.
- Count the dots (including an empty group for zero), then tap one of three
  large number buttons. Incorrect answers invite another look; no lives/timer.
- Trace: follow the moving coloured marker along the dotted numeral, starting
  at 0. Lifting and resuming is fine. Each completed trace advances through 10,
  then loops. Twenty-pixel tolerance accommodates a finger or capacitive stylus.
  These are deliberately simple single-stroke print guides, not a handwriting
  assessment or formal school stroke-order curriculum.
- Compare: tap the larger group for More, smaller group for Less. The game
  alternates after each success. Groups are never equal.
- The bottom arrow returns to the mode selector, even during celebration.
- Completed activities report through `sys.score` for play logging, without a
  competitive failure screen. There is no new save schema or persistent mastery.

## Theme and assets

Uses the installed theme's existing `tilt_wall` and `tilt_wall_sh` values, with
an Outdoors fallback. Dark theme-coloured buttons retain white digit contrast.
Game-owned art per theme in `art/<theme>/`: `field.png` (the theme's `bg_pond`
page, Bounce Back's field), `thing_a..d.png` (the theme's four countables from the
approved design pass, 36 px), `bead.png` (7 px trace dot) and `_tile.png` (cut from
the same field with the countables and the 3 badge). Built from the shipped theme
sets by `tools/newgames/review_prototypes.py build`; no shared themes are changed.

For later integration, use **FORMAT-7 game-owned bundle**, ID `numbers`, script
`main`, `art_needed` listing the six `pack.json` images, plus each theme's images
and `_tile`. `pack.json` is candidate
source metadata, not a catalogue entry. Do **not** use the legacy rules-only
builder and expect shell-only themes to supply these images. No firmware changes
are required by these rules. Signing/release remains the parent's gated step.

## Verification

From the project root:

```
game-library/src/numbers/tests/run.sh
```

This compiles the **vendored Lua interpreter** and exercises rules against a
strict graphics/system mock based on `main/gamehost.cpp` (not real LVGL). It
checks all five actual theme-name palettes, 100 count rounds including all 0–10
values and distinct choices, incorrect-answer retry, all eleven ordered traces,
lift/resume and off-path rejection, no repeated celebration scoring, forty
alternating unequal comparison rounds, menu return and border taps. It checks
integer graphics arguments, image-only recolour/opacity, object-ID validity and
no allocations after `init`. 356 objects remain below the host's 512 lifetime
ID cap. The 7px bead is an image because `gfx.opa`/`gfx.recolor` are image-only;
using boxes for mutable-colour dots would silently fail on hardware.

**Remaining review gates:** real LVGL/round-display appearance, finger usability,
frame time, memory fragmentation on actual hardware, and final signed-bundle
validation. No hardware claims are made by the mock tests. No audio clips are
included; gentle existing beeps are used. School-specific numeral shapes and
number progression can be adjusted after Will/Matilda try it.
