# Sweetcorn Arcade 2026.11.4

# Sweetcorn Arcade 2026.11.4

## Changes
- Paired iPhone can request a signed firmware check/update.
- Console waits until awake, idle, online and connected to external power; it never interrupts a game, pairing or PIN entry.
- Durable request state prevents duplicate update starts after restarts. Pending requests expire; disconnecting or revoking access cancels them.
- App distinguishes request acceptance from a confirmed update, up-to-date result or failure. The new image must complete its normal trial boot before success is reported.
- Existing pairing, games, themes, saves, approvals and playtime remain unchanged. No game/theme packs are included.

## Bootstrap installation
Install this version once using Settings → Update firmware on the console. Older firmware does not implement the phone-update command. Check About → 2026.11.4, leave the console awake for one minute, then Sync in the iPhone app. Future firmware checks/updates can then be requested in the app. Keep the console awake, on Wi-Fi and plugged into power.

Normal signed OTA preserves data. The factory binary is FULL-ERASE recovery/install material, not a recommended update path. No console has been automatically flashed.

## Verification
91 sanitizer-backed companion checks, 19226 shell checks, 4 rollback checks and 27 server tests passed. ESP32-S3 release build succeeded. App binary version/header, partition fit, release-key signature and factory app/partition byte identity verified. Physical-console end-to-end update, power behaviour and browser USB flashing remain unverified.

The iPhone app includes Sync, console last-seen/offline feedback and update controls. 15 Swift checks and iOS build passed; installed on the maintainer’s iPhone. Companion service schema is active. Private-service and provisioned-app limitations remain; no public App Store distribution or push notifications. New game-owned packs remain held back.
