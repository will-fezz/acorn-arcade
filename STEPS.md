# Sweetcorn Arcade 2026.11.16 — power controls and restart history

- Adds Settings → Turn off with a separate cancellable countdown, using the AXP2101 power-chip shutdown command.
- Requires a stable BOOT-button release before entering deep sleep and restores normal BOOT pin control after waking.
- Background downloads no longer wake a dark screen or cancel the sleep/off countdown.
- Saves the last four restart causes across power cycles, with readable history in About, to help diagnose unexpected waking without a USB monitor.

Use the normal signed firmware update to preserve pairing, settings, installed games and saves. The browser factory installer is for initial installation and fully erases the device. Game packs and themes are unchanged; firmware15 queue improvements are retained.

Validation: ESP-IDF build and software regression tests pass (14,048 shell checks and 4 rollback checks); restart-history tests cover persistence across observer resets. Hardware validation remains pending. The reported spontaneous wake on battery after holding BOOT is NOT confirmed fixed. Full shutdown on battery/USB, subsequent power-on, and sleep duration still need physical testing. USB charging and power-management circuitry may remain active while off.
