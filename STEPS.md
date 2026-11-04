# Sweetcorn Arcade 2026.11.10

Revision 2 replaces the original 2026.11.10 build before the test console installed it. Firmware still reports 2026.11.10; use the -r2 downloads below. A console already on the original 2026.11.10 will not automatically install a same-version revision.

- Restores the app's theme choices automatically after console restart, without requiring a pending game download or a manual catalogue refresh. Catalogue requests are signed and verified, run only when safe, and retry with backoff.
- Retains the Numbers restart fix: game graphics use external memory, leaving internal memory for Wi-Fi.
- Retains the theme-artwork fix, persistent installing/update screens and remembered main-menu position.
- Normal OTA preserves games, themes, saves and pairing. No theme is selected or installed automatically; a previous failed theme change remains a failure until explicitly retried.

ESP32 build, signatures and host regressions verified before release. Physical verification of this revised build remains pending. Use the normal console/app update flow; USB factory installation is for recovery/fresh installs.
