# Sweetcorn Arcade 2026.11.5

# Sweetcorn Arcade 2026.11.5

Moves brightness, volume, screen-off time, idle clock, game removal, saved-data
deletion, themes, 30 extra minutes and console passcode management into the
Sweetcorn iPhone app. These controls are removed from the console menu; Wi-Fi,
PIN-protected pairing and recovery remain on the console.

Normal game removal keeps saves unless explicitly selected otherwise. Saved
data can also be deleted independently, including after a game is removed.
Changing a theme keeps the previous theme until its signed replacement is ready.
The app distinguishes theme request acceptance from confirmed activation.

30 extra minutes overrides play-hour restrictions for 30 wall-clock minutes
from console execution; it does not change the daily allowance. It survives
restart without being extended by replay. Interrupted phone operations are
reconciled before new gameplay can create save data.

## Verification

- 109 companion protocol/replay/privacy checks passed.
- 13,547 real-LVGL shell/layout/input/power/UI checks passed with signed theme6
  fixtures, plus four firmware-rollback checks.
- Pack-room/removal scope and saved-data deletion tests passed.
- ESP-IDF ESP32-S3 build passed with no warnings.
- Emitted C++ snapshot validated against the deployed service schema.
- Firmware release-key signature and image version 20261105 verified.
- Matching factory app, partition table and OTA-data bytes verified; factory
  header DIO / 80 MHz / 32 MB verified.

**Physical-console end-to-end controls, OTA and USB flashing remain unverified.**
No console has been automatically flashed. The iPhone app and private companion service are updated; public App Store distribution and push notifications are not available. New game-owned packs remain held back.

## Installation

Preferred: from Sweetcorn, request firmware update while the console is awake,
on Wi-Fi and connected to power. Firmware 2026.11.4 already supports app-started
updates. Normal OTA preserves installed games and saved data.

**Factory image: FULL ERASE / fresh USB installation only.** Do not use it as a
normal update. Factory installation can erase Wi-Fi settings, pairing, games,
passcode and saved progress. No factory installation was performed here.
