# Sweetcorn Arcade 2026.11.6

# Sweetcorn Arcade 2026.11.6

Fixes missing Play activity in the Sweetcorn iPhone app. The console now sends
per-game totals from its 30 most recent completed play sessions, including
existing recorded sessions. Minutes are rounded up after summing each game.
This is recent recorded history, not a daily total or live gameplay timer.
An unavailable log remains unknown rather than being reported as zero.

App-requested firmware updates can now start with battery strictly above 25%,
or while connected to external power. Unknown battery requires external power.
The console must still be awake, idle and on Wi-Fi; signature and rollback
safeguards are unchanged.

## Verification and limitations

- 115 companion checks passed, including battery boundary and activity reporting.
- Activity aggregation checks passed with address/undefined-behavior sanitizers.
- Nonempty C++ activity snapshot passed the deployed service schema.
- ESP-IDF ESP32-S3 release build passed; signed image and factory layout verified.
- Catalogue checked with the shipped C parser; game/theme entries unchanged.
- Physical-console activity reporting and this update's OTA remain unverified.
- No new game-owned packs are published in this release.

## Installation

Use the normal firmware update from Sweetcorn or the console. For the first
update from 2026.11.5 or older, connect external power because the installed
firmware still requires it. Keep the console awake, idle and on Wi-Fi.
Normal OTA preserves games and saved progress. Publication does not initiate
installation on your console.

The matching USB factory installer is for fresh installation only: **FULL ERASE**
can remove Wi-Fi settings, pairing, games, passcode and saved progress.
