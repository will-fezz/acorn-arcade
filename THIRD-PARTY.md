# Third-party work in the Sweetcorn firmware

- **LVGL** 9.5.0: MIT. Comes through the ESP-IDF component manager; its licence is in `managed_components/lvgl__lvgl/LICENCE.txt`.
- **Lua** 5.4.8: MIT. In `components/gamepack/gamepack_lua`.
- **libsodium** (subset): ISC. Comes through `esphome/libsodium`.
- **miniz** (tinfl, the inflater), from firmware 6: the console calls the copy in the ESP32-S3's ROM, through ESP-IDF's `esp_rom` `miniz.h`, so no miniz code is in the firmware image. The host tests build miniz 3.0.2 (MIT, Copyright 2013-2014 RAD Game Tools and Valve Software, 2010-2014 Rich Geldreich and Tenacious Software LLC) from `tests/third_party/miniz`, with its licence there; it is not shipped.
- **Sniglet** and **Nunito** fonts: `main/fonts/sn_*` and `nu_*` are converted from `../tools/fonts` (Sniglet 2.000 and Nunito ExtraBold 3.602, the Google Fonts releases). Both are under the SIL Open Font License 1.1, which asks for its text and the copyright notices to go with the fonts when a product is shared with others. They are in `licences/OFL-Sniglet.txt` and `licences/OFL-Nunito.txt`, unchanged from `google/fonts`, `ofl/sniglet/OFL.txt` and `ofl/nunito/OFL.txt`. Neither licence reserves a font name. `game-library/licences` holds the same files, and `tools/stage_delivery.sh` puts them in the delivery and in `minimal/`.
- **Tilt-a-tron** (PartiallyFrozen/tilt-a-tron, MIT, Copyright (c) 2026 PartiallyFrozen):
  - Tilt, from firmware 5: `the firmware’s tilt.c` is derived from its tilt reading and calibration. That covers the axis mapping from the QMI8658, calibration by lying flat and still for 1.5 s, the offsets, and the gravity scale clamped to 0.85 to 1.15. The MIT licence applies; its text is in `licences/MIT-tilt-a-tron.txt` and `game-library/licences/MIT-tilt-a-tron.txt`, and travels with the firmware and the library.
  - The tilt maze pack (`game-library/src/tilt`) is our own Lua port of the console's earlier tilt maze, not Tilt-a-tron code.
  - Three-strike safe mode: only the idea came from it. `safemode.c` was written from the idea.
  - See `../TILT-A-TRON-COMPARISON.md`.
