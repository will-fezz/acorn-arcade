# Sweetcorn Arcade 2026.11.9

- Fixed theme artwork disappearing with larger installed-game libraries. The menu now keeps only nearby game tiles in memory, and preserves existing artwork if a reload fails.
- Game-install progress stays visible through the whole queued batch.
- Firmware-update progress remains visible through reboot and boot verification.
- Returning to the main menu restores the last selected tile, including when newly installed games change the order.

Verified with the actual 14-game library across all five themes, production pack-manager regressions, 13,582 UI checks and four rollback checks. ESP32 build and release signatures verified. Physical-console verification follows installation.

Existing games, themes, pairing and saves are preserved by the normal OTA update. Use the console's normal firmware update flow; the web installer is for USB factory installation.
