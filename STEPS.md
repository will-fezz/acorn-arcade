# Sweetcorn Arcade 2026.11.10

- Fixes console restarts when launching graphics-heavy games such as Numbers. Game graphics now use external memory, preserving internal memory required by Wi-Fi.
- Retains the 2026.11.9 theme-artwork fix, persistent installing/update screens and remembered main-menu position.
- Normal OTA preserves installed games, themes, saves and pairing.

The original failure was captured on a physical console. The repair passed 1,099 allocator checks, 695 game-host checks, 13,582 UI checks and four rollback checks, plus the ESP32 target build and signature checks. Physical verification of the repaired firmware remains pending.

Use the normal console/app firmware update flow. The USB factory installer is for fresh installation/recovery, not the normal update path.
