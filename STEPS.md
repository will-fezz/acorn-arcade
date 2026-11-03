# Sweetcorn Arcade 2026.11.3

## Changes
- Reports the installed theme ID and version to the paired Sweetcorn iPhone app, enabling its console page to match the console theme. Home remains neutral.
- Preserves existing pairing, approvals, playtime controls, saves, games and themes. No new game or theme packs are included.

## Install
Keep the console charging and connected to Wi-Fi. Choose **Settings → Update firmware**. After restart, check **About → 2026.11.3**, leave the console awake for a minute, then reopen Sweetcorn on the phone. The matching console page updates after its next successful sync. Normal OTA preserves data; do not use the full-erase USB installer for this update.

## Verification and known limitations
ESP32-S3 build, 64 companion host checks, 26 server checks, 13 simulator checks and 14 iOS Core checks passed. The redesigned iPhone app is installed and the compatible server schema is active. **Physical-console verification of this firmware and end-to-end theme matching is pending.** Browser USB flashing is also unverified. Sleeping/offline consoles cannot sync; the app stays neutral until it receives a reported theme. Existing experimental private-service companion limitations remain: no public App Store distribution or push notifications.

New game-owned artwork packs remain held back. Version 2026.11.3 uses compatible numeric image/catalogue version 20261103. The attached binary is app-only; the separate USB installer is full-erase recovery.
