# Sweetcorn Arcade 2026.11.15 — game-install queue reliability

- Extra phone installs wait safely when the console's eight active request slots are full, then resume without another tap.
- A waiting catalogue request no longer holds up ready unrelated game requests or firmware recovery commands.
- Same-game remove/retry operations retain their ordering behind deferred installs.
- Incompatible games return a clear instruction to update console firmware first.
- Firmware updates can start from the idle installation-progress page.
- Successful downloads no longer impose an artificial 30-second delay before the next game; refused starts retain retry backoff.
- Reports the supported game-engine version for companion-app compatibility checks.

All game packs and themes are unchanged from firmware14's release. Engine7 and firmware13/14 improvements are retained. Use the normal signed firmware update to preserve pairing, settings, installed games and saves; the browser factory installer is for initial installation.

Validation: 702 companion checks, a 20-install burst/drain regression, host shell checks and ESP-IDF build passed. Companion safeguards were also software-tested separately. Physical-console installation and burst behaviour must be verified independently; test results are not hardware proof.
