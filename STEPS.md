# Sweetcorn Arcade 2026.11.2

## Changes
- Adds PIN-gated phone pairing: start on the console, scan or enter its code in the authenticated Sweetcorn app, then confirm physically on the console. Codes expire after five minutes.
- Adds remote game approval/denial, playtime settings and status snapshots while the console is awake. Approved games still need a successful signed download before they appear installed.
- Credentials and request identities persist; expired, stale and replayed commands are guarded by a durable receipt journal.
- Keeps Wi-Fi available for paired controls with modem power saving. Sleeping/offline consoles are not reachable.

## Install and pair
Keep the console charging and connected to Wi-Fi. Open **Settings → Update firmware**. After restart, check **About → 2026.11.2** and leave it running for a minute. This normal OTA update preserves settings, saves and installed packs.

Unlock the parental PIN, open **Settings → Pair phone**, and explicitly start pairing. In the configured Sweetcorn app, scan the QR or enter its code. Then confirm on the console while its pairing page remains unlocked. Leaving cancels an unconfirmed pair.

## Verification and limitations
Successful ESP32-S3 build; 62 companion fault-injection checks, 19,226 real-LVGL host checks and four rollback checks passed. The private HTTPS service and iOS simulator have passed their software checks. **Real-console pairing, power-loss recovery, running-game behaviour, RAM margin and battery use remain unverified.** Physical browser USB flashing is also unverified.

This is an experimental private-instance integration, not a generally available iPhone product. The current build targets the maintainer's configured service; the app needs its provisioned owner access. Consumer accounts, App Store distribution and push notifications are unfinished. Remote firmware updates, theme changes and game deletion are not enabled. Disconnect on the console clears local credentials; revoke its old app entry to remove the server association.

Existing game/theme packs are unchanged; new game-owned artwork packs remain held back. Public version 2026.11.2 uses compatible numeric image/catalogue version 20261102. Attached binary is app-only, not a factory flash image. Use the normal console updater; the separate browser installer is full-erase recovery.
