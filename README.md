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

> **Development project, not a finished product.** Latest firmware: **2026.11.2**. Automated checks passed; real-console verification of the fixes is still pending.

## Latest update — 2026.11.2

## Changes
- Adds PIN-gated phone pairing: start on the console, scan or enter its code in the authenticated Sweetcorn app, then confirm physically on the console. Codes expire after five minutes.
- Adds remote game approval/denial, playtime settings and status snapshots while the console is awake. Approved games still need a successful signed download before they appear installed.
- Credentials and request identities persist; expired, stale and replayed commands are guarded by a durable receipt journal.
- Keeps Wi-Fi available for paired controls with modem power saving. Sleeping/offline consoles are not reachable.

## Install and pair
Keep the console charging and connected to Wi-Fi. Open **Settings → Update firmware**. After restart, check **About → 2026.11.2** and leave it running for a minute. This normal OTA update preserves settings, saves and installed packs.

Unlock the parental PIN, open **Settings → Pair phone**, and explicitly start pairing. In the configured Sweetcorn app, scan the QR or enter its code. Then confirm on the console while its pairing page remains unlocked. Leaving cancels an unconfirmed pair.

## Verification and limitations
Successful ESP32-S3 build; 62 companion fault-injection checks, 19,226 real-LVGL host checks and four rollback checks passed. The private HTTPS service and iOS simulator have passed their software checks. **Real-console pairing, power-loss recovery, running-game behaviour, RAM margin and battery use remain unverified.** Physical browser USB flashing is also unverified.

This is an experimental private-instance integration, not a generally available iPhone product. The current build targets the maintainer's configured service; the app needs its provisioned owner access. Consumer accounts, App Store distribution and push notifications are unfinished. Remote firmware updates, theme changes and game deletion are not enabled. Disconnect on the console clears local credentials; revoke its old app entry to remove the server association.

Existing game/theme packs are unchanged; new game-owned artwork packs remain held back. Public version 2026.11.2 uses compatible numeric image/catalogue version 20261102. Attached binary is app-only, not a factory flash image. Use the normal console updater; the separate browser installer is full-erase recovery.

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
3. After restarting, check that About shows **2026.11.2**, and leave it running for a full minute to confirm the update.
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
| Firmware 2026.11.2 signed update | Real-console verification of rapid taps, scrolling and downloads |
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

Open the [Sweetcorn USB installer](https://will-fezz.github.io/acorn-arcade/) in desktop Chrome or Edge. For the Waveshare ESP32-S3-Touch-AMOLED-1.75C (32 MB) only. **Fresh install/recovery erases settings, saves and installed games/themes.** Use Settings → Update firmware on an existing console to keep data. The installer uses released firmware 2026.11.2, including experimental private-instance companion support. Physical browser USB flashing remains unverified.
