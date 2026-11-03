<p align="center">
  <img src="assets/sweetcorn-mascot.png" width="300" alt="Sweetcorn Arcade — a cheerful cartoon sweetcorn holding a round games console">
</p>

<h1 align="center">Sweetcorn Arcade</h1>
<p align="center"><strong>A little console. A whole lot of play.</strong></p>
<p align="center">10 games · 5 illustrated themes · 1 tiny round touchscreen</p>
<p align="center"><a href="#pick-your-game">Games</a> · <a href="#choose-your-world">Themes</a> · <a href="#get-playing">Get started</a> · <a href="#on-the-workbench">Development</a></p>

---

Sweetcorn Arcade is a DIY handheld games project built around an ESP32-S3 and a 1.75-inch AMOLED touchscreen. Tap, tilt, remember and react in short games, then change the scenery with a different illustrated theme.

Installed games run on the console. Wi-Fi brings new games, themes and signed firmware updates.

> **Development project, not a finished product.** Latest firmware: **2026.11.5**. Automated checks passed; real-console verification of the fixes is still pending.

## Latest update — 2026.11.5

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

## Pick your game

| Game | The idea |
|---|---|
| **Snake** | Guide a growing snake. |
| **Balloons** | Tap and pop balloons. |
| **Tilt** | Play using the console's tilt controls. |
| **Pet** | Look after a little virtual companion. |
| **Copy Me** | Watch a pattern and repeat it. |
| **Do It Quick!** | React to the next instruction. |
| **Bounce Back** | Keep the ball in play. |
| **Pop-Up Tap** | Catch the pop-ups with a tap. |
| **Switch Off** | Work through a lights puzzle. |
| **Hungry Monster** | Feed a hungry character. |

All ten appear in the [published catalogue](catalogue.json). Host testing covers the games across five themes; complete real-device verification is still in progress.

## Choose your world

**Outdoors** · **Space** · **Dinosaurs** · **Unicorns** · **Manga**

Five different looks for the same collection of games. Change your theme through **Settings → Themes**.

**How artwork works today:** the published theme packs contain game artwork, including pictures for games you have not installed. Removing a game does not currently remove its pictures from a shared theme.

**The next design:** each game pack will carry that game's pictures for all five themes. Theme packs will keep shared interface artwork. Removing a game will then remove its bundled pictures too. Firmware support is included, but the new game-owned packs are **held back** pending real-console confirmation; existing packs remain unchanged.

## Get playing

### Already have the development console?

1. Keep it charging and connected to Wi-Fi.
2. Open **Settings → Update firmware**.
3. After restarting, check that About shows **2026.11.5**, and leave it running for a full minute to confirm the update.
4. Download a current theme through **Settings → Themes**.
5. Choose games through **More games**, then approve them under **Settings → Downloads**.

Install the latest firmware before changing themes. See [update and recovery instructions](STEPS.md) for more detail.

**If a download reports insufficient memory:** this release includes a fix for the identified working-memory allocation failure. Actual pack storage can still fill up; use grown-up game removal to free space. Do not erase the console or saved progress as a workaround. Please report failures that remain.

### Starting with a bare board?

The development target is the **Waveshare ESP32-S3-Touch-AMOLED-1.75C, 32 MB configuration**. The 1.75 and 1.75C variants are not interchangeable.

This repository is currently a distribution library for an already provisioned console, **not a complete hardware kit or reproducible public firmware build**. Complete source packaging, pinned dependencies and verified setup instructions remain to be prepared. Hardware assembly and flashing are adult tasks.

## On the workbench

| Published now | Still being worked on |
|---|---|
| Firmware 2026.11.5 signed update | Real-console verification of rapid taps, scrolling and downloads |
| Ten game packs and five compressed themes | Release of game-owned artwork packs after console confirmation |
| Retained-save deletion after uninstalling a game | Physical pairing tests, app distribution and automated game submission checks |
| PIN-protected game removal, with saves kept by default | Full source packaging and security/licence audit |

Host checks do not replace testing on the actual console. New artwork packs remain held back; this release does not replace existing games or themes.

## For makers

The games use Lua inside a restricted host. Downloads are checked using signed catalogues and packs; firmware also has hash, signature and image checks. Signing protects authenticity, not against every bug. Test-key retirement and the final security/dependency audit remain release work.

Want to propose a game? Open an issue or pull request with the idea, controls, Lua source, memory/save requirements, theme artwork and the origin and licence of every asset. The intended route is review, hardware playtesting, then maintainer signing. Automated submission checks are not yet operational.

Keep contributions free of advertising, tracking, purchases and chat. Installed play is local; settings, progress and play-duration records can be stored on the device. Download hosts receive normal connection information. An experimental parent app now connects to the maintainer’s private service; pairing sends console status, requests and playtime settings to that service. It is not a public consumer service.

## Name, artwork and licences

**Sweetcorn Arcade** is the new project name, replacing Acorn Arcade. The repository address and internal identifiers still use `acorn-arcade` / `acorn` to preserve existing update URLs and compatibility. Older firmware may still show the previous branding.

The mascot was newly AI-generated for this rebrand. Names are not represented as trademark-cleared, and a new name does not settle rights in third-party game names or assets.

There is **no blanket MIT licence grant** for this repository. MIT for original code remains proposed pending an authorised notice; third-party code, fonts and artwork retain their own terms. Read [THIRD-PARTY.md](THIRD-PARTY.md) and the bundled notices. The complete provenance and licence audit remains unfinished.

---

<p align="center"><strong>Small games. Big grins. Sweetcorn Arcade.</strong></p>

## USB installation on Mac and Windows

Open the [Sweetcorn USB installer](https://will-fezz.github.io/acorn-arcade/) in desktop Chrome or Edge. For the Waveshare ESP32-S3-Touch-AMOLED-1.75C (32 MB) only. **Fresh install/recovery erases settings, saves and installed games/themes.** Use Settings → Update firmware on an existing console to keep data. The installer uses released firmware 2026.11.5, including experimental private-instance companion support. Physical browser USB flashing remains unverified.
