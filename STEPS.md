# Sweetcorn Arcade 2026.11.13 — daily allowance usage

Reports the console’s local date and used daily-allowance minutes to the companion app, including its active game. The Playtime page can show used minutes out of the applied allowance, a progress bar and remaining allowance. Readings are labelled with their date and last-sync status; extra playtime stays separate.

The updated companion mailbox and iPhone app are required and have been deployed. Unknown clock or unreadable play history reports unavailable usage, never a made-up zero. Older firmware remains compatible with the app and mailbox.

Allowance enforcement is unchanged. Telemetry shares the enforcement counter; completed sessions retain their start-day attribution and existing rounding, and active sessions retain existing cross-midnight accounting. This is an allowance counter, not a new wall-clock timekeeping policy. No pairing, saves, settings or persisted-data layouts change.

Includes 2026.11.12’s automatic signed-catalogue refresh and game-install recovery. All current games, theme packs and artwork are retained unchanged.

Verification: 661 companion checks, 13,630 UI checks, 4 rollback checks and 404 core/pack/crypto checks passed. ESP32-S3 production build, image version/size, Ed25519 signature and matching factory layout verified. Physical-console telemetry is not verified until installation and a subsequent sync.

Use the normal signed firmware update to preserve console data. The factory image is for first installation/recovery, not updating an existing console.

Published release; physical-console verification follows installation.
