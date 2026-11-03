# Sweetcorn Arcade firmware 7 — update order

This is a staged development release. Do not claim it has been tested on the console until the checks below have actually been done. The existing `will-fezz/acorn-arcade` repository address, signing keys and game/save IDs are unchanged.

## 1. Update firmware first

Publish only the `step-1-bridge` files listed in the parent delivery's `PUBLISH-FILES.txt`. Its catalogue retains today's version-6 themes and rules, and offers firmware 7. Keep the console charging, choose Settings → Update firmware, and check About shows 7. Leave it running for at least a minute so the trial confirms. No packs can be installed during the trial.

The reserved downloader stack in firmware 7 cannot repair the already-running firmware 6 before the update. If the firmware-6 updater itself cannot complete, preserve the console and its saved data; use the documented board-specific recovery with the operator, not an erase-all shortcut.

## 2. Upgrade installed games, then the theme

After firmware 7 is confirmed on the console, publish `step-2-full` as listed. The full catalogue retains old entries for firmware 6; firmware 7 chooses the newest compatible version and shows one row per item.

1. Open More games → Look for games. Installed games with new packs appear here too.
2. Request version-7 packs for the games you already have. Approve them in Settings → Downloads. Download one at a time. Existing progress and game IDs are retained.
3. Then use Settings → Themes → Look for themes and update the current theme to version 7.
4. If a legacy rules-only game is still installed, the small theme will be refused with “Update installed games first, then this theme”. The old theme remains. Update or remove that game and retry the theme.

Each version-7 game bundle contains its code, gameplay pictures and selector tile for **all five themes**. Only the selected theme's gameplay pictures are loaded into RAM. Version-7 themes hold the shared interface, palette and names; they have no game pictures. Removing a bundled game frees all of its bundled pictures, including all five tiles. Until the old shared theme has been replaced, it still holds its legacy copy of the pictures.

All five sets in each game mean installing every game uses more flash than keeping just one old full theme. The benefit is ownership and predictable removal, not a promise that every installation uses fewer bytes. Allocation is in 256 KiB slots; Settings shows allocated storage, not just compressed file size. Multi-slot bundles are not moved by the legacy rules-only compactor. If there is insufficient contiguous storage, remove an unwanted game and retry; live packs are never erased just to force an update to fit.

## Saved data

Settings → Saved game data lists scores/progress even for removed games. Select the game, then explicitly confirm Delete saved data. Cancel leaves it untouched. This does not uninstall a game or erase play history, settings, other games or version floors. Retained saves live in settings storage, not the game-pack partition; deleting them is not a solution to a pack-storage shortage.

## Memory diagnostics

The exact old “no memory for download” message came from failing to allocate a new 10,240-byte internal-RAM task stack. Firmware 7 reserves one permanent internal stack shared by catalogue refresh, pack downloads, firmware updates and boot pack checks. It is not deleted/reallocated between jobs. HTTPS still needs working memory, and failures there are distinguished from insufficient pack storage.

## Required on-console checks

- Firmware 6 → 7 OTA succeeds; About says 7; no trial rollback or watchdog crash.
- Update all installed games, then the current theme; existing progress survives.
- Switch all five themes, launch each installed game, and inspect the selector tile/art.
- Remove a game with Keep saved data on: allocated pack space increases and its tile vanishes. Reinstall: progress returns.
- Remove it again; Settings → Saved game data still lists it. Cancel deletion once, then confirm. Reinstall: that game's progress is reset; other saves and play history remain.
- Repeat catalogue refresh, successful/failed downloads and game launches; record internal free/largest block and worker stack high-water mark from logs. Host tests do not establish hardware free-memory figures or display timing.
- Test a weak/disconnected network gracefully; do not deliberately interrupt a real update without a separate recovery test plan.

Never downgrade firmware manually to one unable to read installed bundle packs. Do not change repository URLs or trust keys as part of this update.
