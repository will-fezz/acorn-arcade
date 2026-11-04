# Sweetcorn Arcade 2026.11.11

- Fix game/theme download memory refusals by temporarily lending the spare display buffer, then restoring it safely after downloads. Existing memory safety limits and signed-package checks stay intact.
- Add owning-phone Games Store installation support: choose a published game in the updated private iPhone companion app without first requesting it on the console. Downloads still go directly to the console.
- Preserve the automatic theme-list and Numbers graphics-memory fixes from 2026.11.10 revision 2.

Install using the normal firmware update in the app or console, then let the startup check finish. This is the save-preserving path. The browser USB factory installer performs a FULL ERASE and is only for first installation/recovery.

Verification: firmware build, 612 companion checks, download-memory regressions, UI/rollback checks, 37 server tests and 30 Swift Core tests passed. Signed iPhone and simulator builds passed. Physical theme download and new Store installation remain unverified until the updated firmware runs on hardware. Companion support uses the maintainer’s private service and provisioned app; this is not an App Store release.
