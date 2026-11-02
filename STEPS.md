# Firmware 6: every game in every theme, and theme changes that fit

Nothing here has been published or sent to the console. Keep USB ready. GitHub's raw files can take about 5 minutes to refresh. Everything is signed with the real key, which firmware 3 and 5 already trust.

## What changes

- Themes go to version 6 and store their art deflated (zlib). A theme with all ten games is about 1.6 to 2.0 MB (7 to 9 of the packs partition's 94 slots) instead of 11 MB (44 to 45). Two themes and ten games now fit with room to spare, so changing theme works again, from any layout seen in the flash budget check.
- The console unpacks art into PSRAM as before: the menus' art once per theme change, a game's art when it starts. It uses the inflater in the chip's ROM, and checks each image's length and its Adler-32. A theme whose art does not unpack is refused when it is downloaded (the old theme carries on), and one damaged later is caught by the check at every boot.
- Firmware 6 still reads version 4 and 5 themes, so nothing changes until a version 6 theme is downloaded.
- More games says "No new games right now" when every game is installed. Shop, tiles and on-screen titles use the approved names in every theme: Copy Me, Do It Quick!, Bounce Back, Pop-Up Tap, Switch Off and Hungry Monster. Pack IDs stay unchanged.
- For games (engine 5): `sys.time`, `sys.save`/`sys.load`, `gfx.recolor`, `gfx.box`. Pet now keeps its full state and the real time, as the old built-in Pet did.

## Storage and removal

Settings is protected by the grown-up passcode. Games on this console lists installed games and their sizes. Removing asks for confirmation: **Remove, keep its data** is the default; **Remove and delete its data** also clears that game's saved state. Activity history is always retained. With kept data, reinstalling the same pack ID restores it. Removed games return to More games.

The console checks total free space and the largest contiguous free run before a game or theme download. When fragmentation is the only obstacle, it safely relocates verified small game-rule packs before downloading; a copied pack is verified and committed before its old copy is retired. Themes and saved data are not moved. If it cannot fit, the child sees “Not enough room — ask a grown-up”; the grown-up can go straight to the removal page. About shows used and free storage. Removing rules does not rewrite the shared theme pack: that game's artwork is no longer loaded or used, but shared-theme flash bytes are reclaimed only by replacing the theme.

## Why two steps

Firmware 5 hides a pack it cannot read, but when the catalogue has a newer version of a theme, it takes the newest and refuses it ("needs a newer firmware"). Version 6 themes need firmware 6. So firmware 6 goes out first with the packs that are on `main` today, and the version 6 themes only once the console runs firmware 6.

## 1. Publish the bridge: firmware 6 only
From `step-1-bridge/`, copy to the `main` branch of `will-fezz/acorn-arcade`:
- `catalogue.json`, `catalogue.json.sig`
- `firmware/acorn-fw-6.bin`, `firmware/acorn-fw-6.bin.sig`
- `STEPS.md`, `README.md`, `THIRD-PARTY.md`

Every pack it lists (Snake 3, Balloons 1, Tilt 1, themes 4) is byte for byte what is on `main` now, so `packs/` needs no change. `acorn-fw-5.bin` can stay or go: the catalogue no longer lists it.

## 2. Update the firmware
On the charger, close to the access point: Settings tile, passcode, scroll down, Update firmware.

**You should see:** after the restart, About says Firmware 6 and "New: Every game in every theme". The menus look exactly as before (still the version 4 theme). Wait a full minute: until the new firmware confirms itself, downloads say "just updated, try again in a minute".

## 3. Publish the full release
From `step-2-full/`, copy `catalogue.json`, `catalogue.json.sig`, `packs/`, `src/` and `themes/` to `main` (firmware and the rest are the same as step 1). Do not copy `packs-seed.bin.usb-only`. The version 4 theme files on `main` are no longer listed and can be deleted.

## 4. On the console
1. Settings, Themes, Look for themes, then tap the theme in use (download icon). It brings version 6: about 2 MB; download time depends on Wi-Fi.
2. More games: ask for each new game (Switch Off, Bounce Back, Pop-Up Tap, Copy Me, Do It Quick!, Hungry Monster, Pet). Settings, Downloads: Allow.
3. Play each one. A game asked for before step 1 shows "this theme has no art for that game" until the theme is version 6.
4. Change theme: Settings, Themes, pick another. It should download and switch. Then change back. Both work with every game installed.
5. When every game is in, More games says "No new games right now".

**If a theme says "theme refused"** right after its download: the art did not unpack on the console, and the old theme carries on. Stop and send the serial log (packs: "theme ... refused: bad contents"). Nothing else is affected.

## Firmware 3 and 5 on this catalogue
- Firmware 5 (step 2): offered firmware 6 and the ten games, not the version 6 themes. Its version 4 theme stays; the seven new games say they have no art until the console has firmware 6.
- Firmware 3 lists everything and refuses after the download what it cannot run, as before. It still finds firmware 6.

If something is wrong: firmware 5 is still in the other slot. Rollback only happens on a crash in the first minute; for a firmware that runs but misbehaves, the fix is a firmware 7, or USB. A version 6 theme cannot be read by firmware 5: going back to firmware 5 by USB needs a version 4 theme from the USB seed.
