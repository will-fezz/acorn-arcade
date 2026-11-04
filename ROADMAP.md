# Sweetcorn Arcade roadmap

Status as of 2 Nov 2026 (afternoon). Items are plans, not commitments or finished work. Library repo: https://github.com/will-fezz/sweetcorn-arcade

## Now: foundation
**1 Nov:** firmware 2 and the Outdoors theme downloaded from GitHub and installed on the console, confirmed good by Will. Still signed with the test key.

**2 Nov:** rollback test passed on the console: firmware 4 crashed on purpose and it returned to firmware 3 by itself, with games and settings kept; firmware 4 then removed from GitHub. Firmware 3 installed over the air, then Outdoors 3, Snake 3 and Balloons 1 (real signing key) downloaded from GitHub. Will confirms everything works, including Balloons.

1. Done (1 Nov): found why firmware updates to the console stall.
2. Done (1 Nov): tested the secure download and Lua speed on the console.
3. Done (1 Nov, about 20:35): the ESP-IDF firmware `e4009f0` is on the console by USB, with test-key packs (Snake and Outdoors). It boots, with panel, touch, audio and packs working, and Snake plays. Internal heap at boot was 40 KB. This flash removed the other games and the Home Assistant link until they are ported. A full ESPHome backup is on the Mac.
4. Coded, compiled and host tested (1 Nov), not on the hardware: firmware 2, with the themed menus in all five themes and three-strike safe mode. See README, "Firmware 2".
5. Next: the first real over-the-air update, which is firmware 2. It needs a few files on the library's main branch; see README, "Reaching the console". Keep USB ready.
6. Done (1 Nov): firmware 2 installed over the air.
7. Done (2 Nov), on the hardware: firmware 3 installed over the air, with Outdoors 3, Snake 3 and Balloons 1 signed with the real key. The rollback test also passed on the console: firmware 4 crashed on purpose and the console went back to firmware 3 by itself, keeping games and settings. See README, "Firmware 3".
8. Prepared, not on the hardware (2 Nov): firmware 5. It adds tile borders in all five themes (theme version 4), Wi-Fi only when needed, power management and battery logging, `sys.tilt()` with Tilt-a-tron's MIT calibration, and the tilt maze as a signed pack. It is staged in two steps in `delivery/firmware-5`; see README, "Firmware 5". Next: publish step 1, update the console, then publish step 2.
9. Then: port the remaining games and add the Game Shop.

**Tilt-a-tron: option C (decided 1 Nov).** Stay on Sweetcorn and keep porting our own games to Lua. Add tilt to the Lua host using Tilt-a-tron's MIT code, and rewrite only the Tilt-a-tron games the children would actually play. No rebase and no native games for now, because they could not wear the themes and would give up Lua's safety. See `TILT-A-TRON-COMPARISON.md`.

Also needed: pack sounds (Balloons uses a beep for now), deleting games, finishing the move to the real signing key, a backup of that key, and carrying over scores and the pet where possible. Phone hotspot as a second network and Wi-Fi setup from a phone are coded, not yet tried on the hardware.

## Themes

**Planned — Sweetcorn theme (Will, 4 Nov 2026).** Build a complete console theme around the sweetcorn artwork in the current iPhone app icon, now the official Sweetcorn logo. Use warm corn-yellow, leaf-green and friendly kernel/cob details across the home screen, picker and every game’s artwork. Keep the logo consistent with the companion app. This is a roadmap item only: artwork, signed pack, memory/storage checks and on-console verification are not yet complete.

Outdoors, space, dinosaurs, unicorns and manga, with art for every game and the home screen and picker. The console stores the current theme and downloads another when switched. Start with one game in each new theme for approval. Packs for all five, with Snake and the themed menus, build and install in host tests. A new theme is data only: palette, names, art. The four new ones are still marked draft in `game-library/themes`, so the normal catalogue leaves them out; the delivery for firmware 2 lists them so they can be tried on the console.

## Hooks in the rebuild (on the console since 1 Nov; not yet exercised there)
- Play hours enforced on the console, working offline.
- A pending-approval state for Game Shop downloads.
- A local log of what was played and for how long.

## Next big pieces (Will, 2 Nov)
1. Firmware 6 (prepared 2 Nov, not on the hardware): deflated theme art, so all ten games fit in every theme (1.6 to 2 MB a theme) and switching themes works; "No new games right now"; shop names match tile names; `sys.time`, `sys.save`/`sys.load`, `gfx.recolor`, `gfx.box`. Staged in two steps in `delivery/firmware-6`; see README, "Firmware 6". Also included: PIN-protected removal with "keep its data" (default) or "delete its data"; space check before downloads (child: "Not enough room, ask a grown-up"; grown-up: "Free up space before installing this game" with a button to the remove page); space used/free on About; crash-safe rules compaction when fragmentation blocks a download. All six approved display renames preserve pack IDs.
2. Build Matilda's new games, then pack sound clips, then Rosie's and the learning games.
3. iPhone parent app (proper native app recommended, built on the Mac mini; Apple developer account about £79 a year): game approvals with notifications, play hours, activity, installed games and space. Console and phone meet through a small mailbox service (Home Assistant or a tiny server) because the console's Wi-Fi is mostly off. Will to confirm the app type.
4. Submit a game on GitHub: contributors send a pull request using a template and guide; GitHub Actions run the game in the host test in all five themes, with size, API and memory checks; Astra, Eric and Will review and Will plays it; Eric signs it locally with the release key (never on GitHub) and adds it to the catalogue. Submissions MIT-licensed, with written kid-safe content rules (no ads, links, scary content or data collection).

## Future updates
- Optional Home Assistant link over MQTT. The console works fully without it.
- Parent app: see "Next big pieces" 3.
- Firmware updates from anywhere.
- Profiles for each child, with their own scores, theme and pet.
- Age levels for each game.
- Daily surprise: a mini-challenge or pet event.
- Unlockables: stars buy pet outfits or stickers.
- Two-player games between two consoles.
- Bedtime mode: dimmer, quieter, with a goodnight from the pet.
- Parent-set volume cap.
- Find my console: play a sound from Home Assistant or the app.

## Will's menu changes (1 Nov, after seeing firmware 2)
Built into firmware 3 with the approved designs, painted tiles, battery and Wi-Fi glyphs and clock in all five themes. Compiled and host tested, not on the console.
- Use the "More games" background on the clock and the home screen, in every theme.
- Snake tile is square: make it a circle like the others.
- Clock: centre the battery, and give it more design. Redesign the battery and Wi-Fi icons on the main menu.
- Fun painted icons for More games and Settings, in every theme.
- Passcode: dots look squished at the top; new-passcode digits look squished. Add a confirm step (enter the new passcode twice).

## Next update (Will, 2 Nov)
Both items below are built into firmware 5: compiled and host tested, not yet on the console.
- Snake and Clock tiles lack the full painted border ring the other tiles have; give every tile a full border in all five themes.
- Wi-Fi only when needed (Will, 2 Nov): radio off during games and the clock; on for More games, Settings (Wi-Fi, Themes, Downloads, Update firmware), and a short daily time sync, then off again after a minute idle. Keep play hours and the clock working offline. Confirm Bluetooth is disabled in the build (it already is: no BT in sdkconfig) and save its RAM.

## After firmware 5: games (Will, 2 Nov)
- Port back the remaining built-in games: Simon, Bop It, Lights Out, Pong, Feed the Monster, Pet, Whac-a-Mole (Snake, Balloons done; tilt maze in firmware 5).
- New: letter tracing (finger or capacitive stylus, one big letter at a time, handwriting style chosen in grown-up settings: print now (default), cursive later; lowercase and capitals options); numbers for Matilda (count objects, tap the number, trace 0-10, more/less); Tic-tac-toe (two players or easy computer); Boxes (dots and boxes, two players or computer); Block Basher (round breakout, own code inspired by Tilt-a-tron's idea).
- Ideas proposed, not agreed: Rosie games (tap to make things happen, animal sounds, colours, shapes, pop and peekaboo) and more learning games (phonics sounds, matching pairs, shapes and colours sort, patterns).
