# Sweetcorn Arcade 2026.11.7

# Sweetcorn Arcade 2026.11.7

Fixes the phone-command journal filling after 32 retained commands. Protocol v2
assigns stable server serials and persists a replay barrier before reclaiming
confirmed receipts. Existing pairing, pending intent, game packs and saves keep
their existing storage layout. Duplicate commands stay non-executable across
restarts and interrupted writes; this is not a larger fixed buffer.

Approved game downloads now retry fairly and report local wait/error reasons
(wake console, exit game, busy, Wi-Fi or memory) to the companion app instead of
silently remaining approved. The app distinguishes approval from installation.
The compatible private companion service must be upgraded before this firmware.

## Verification and limitations

- 579 companion checks passed under address/undefined-behavior sanitizers,
  including 96 unique commands, reboot/replay, failed persistence, expiry and v1 migration.
- 36 service tests passed, including 96-command/reconnect runs, legacy response
  compatibility, migration, gap-safe retirement and monotonically allocated IDs.
- ESP-IDF ESP32-S3 release build passed; signed image/factory layout and shipped
  C catalogue parser checked before publication. Game/theme packs unchanged.
- Real-console protocol-v2 operation and Letter Tracing installation are not yet
  hardware-verified. Publication does not prove or initiate console installation.

## Installation

For a console whose old phone journal is full, use the console's own
**Settings → Update firmware** (enter its current passcode), not another phone
update command. Keep it awake, idle, near Wi-Fi and on external power. Normal
signed OTA preserves pairing, games and saves. After it reconnects, verify the
reported firmware and installed games; do not resend an existing approval.

The matching USB factory image is for fresh installation only: **FULL ERASE**
can remove pairing, Wi-Fi, games and saved progress. Do not use it for this repair.
