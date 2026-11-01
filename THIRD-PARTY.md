# Third-party work in the Acorn firmware

- **LVGL** 9.5.0: MIT. Comes through the ESP-IDF component manager; its licence is in `managed_components/lvgl__lvgl/LICENCE.txt`.
- **Lua** 5.4.8: MIT. In `components/gamepack/gamepack_lua`.
- **libsodium** (subset): ISC. Comes through `esphome/libsodium`.
- **Sniglet** and **Nunito** fonts: `main/fonts/sn_*` and `nu_*` are converted from `../tools/fonts` (Sniglet 2.000 and Nunito ExtraBold 3.602, the Google Fonts releases). Both are under the SIL Open Font License 1.1, which asks for its text and the copyright notices to go with the fonts when a product is shared with others. They are in `licences/OFL-Sniglet.txt` and `licences/OFL-Nunito.txt`, unchanged from `google/fonts`, `ofl/sniglet/OFL.txt` and `ofl/nunito/OFL.txt`. Neither licence reserves a font name. `game-library/licences` holds the same files, and `tools/stage_delivery.sh` puts them in the delivery and in `minimal/`.
- **Tilt-a-tron** (PartiallyFrozen/tilt-a-tron, MIT): the idea of three-strike safe mode came from it. No code was copied: `components/acorn_core/safemode.c` was written from the idea, so its licence does not apply, and this line is a courtesy. See `../TILT-A-TRON-COMPARISON.md`.
