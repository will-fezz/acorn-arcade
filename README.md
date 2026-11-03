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

> **Development project, not a finished product.** Firmware 6 and the ten-game library are published. Download-memory and saved-data management issues are under investigation. This new name and mascot are a branding update, not a firmware release.

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

**The next design:** each game pack will carry that game's pictures for all five themes. Theme packs will keep shared interface artwork. Removing a game will then remove its bundled pictures too. This is planned for firmware 7 and is **not yet released**.

## Get playing

### Already have the development console?

1. Keep it charging and connected to Wi-Fi.
2. Open **Settings → Update firmware**.
3. After restarting, check that About shows **Firmware 6**, and leave it running for a full minute to confirm the update.
4. Download a current theme through **Settings → Themes**.
5. Choose games through **More games**, then approve them under **Settings → Downloads**.

Install firmware 6 before the version-6 themes. See [update and recovery instructions](STEPS.md) for more detail.

**If a download reports insufficient memory:** this is a known report still being investigated. The wording alone does not establish whether working RAM or pack storage is exhausted. Do not erase the console or saved progress as a workaround. Game artwork still in shared themes is a separate storage limitation.

### Starting with a bare board?

The development target is the **Waveshare ESP32-S3-Touch-AMOLED-1.75C, 32 MB configuration**. The 1.75 and 1.75C variants are not interchangeable.

This repository is currently a distribution library for an already provisioned console, **not a complete first-flash kit or reproducible public firmware build**. Complete source packaging, pinned dependencies and verified setup instructions remain to be prepared. Hardware assembly and flashing are adult tasks.

## On the workbench

| Published now | Still being worked on |
|---|---|
| Firmware 6 signed update | Firmware 7 game-owned artwork |
| Ten downloadable game packs | Diagnosis and repair of download-memory failures |
| Five compressed theme packs | A way to delete retained saves after uninstalling a game |
| PIN-protected game removal, with saves kept by default | Real-device storage, theme-switching and update checks |

Keeping progress when uninstalling should not make it impossible to delete later. Retained-save management is part of the requested next update; it is not presented here as fixed.

Firmware 6 passed target-build, host-test and signing checks. Those checks do not replace testing on the actual console. No firmware 7 download is advertised until a build is ready and released.

## For makers

The games use Lua inside a restricted host. Downloads are checked using signed catalogues and packs; firmware also has hash, signature and image checks. Signing protects authenticity, not against every bug. Test-key retirement and the final security/dependency audit remain release work.

Want to propose a game? Open an issue or pull request with the idea, controls, Lua source, memory/save requirements, theme artwork and the origin and licence of every asset. The intended route is review, hardware playtesting, then maintainer signing. Automated submission checks are not yet operational.

Keep contributions free of advertising, tracking, purchases and chat. Installed play is local; settings, progress and play-duration records can be stored on the device. Download hosts receive normal connection information. A parent app is an idea, not an available feature.

## Name, artwork and licences

**Sweetcorn Arcade** is the new project name, replacing Acorn Arcade. The repository address and internal identifiers still use `acorn-arcade` / `acorn` to preserve existing update URLs and compatibility. Older firmware may still show the previous branding.

The mascot was newly AI-generated for this rebrand. Names are not represented as trademark-cleared, and a new name does not settle rights in third-party game names or assets.

There is **no blanket MIT licence grant** for this repository. MIT for original code remains proposed pending an authorised notice; third-party code, fonts and artwork retain their own terms. Read [THIRD-PARTY.md](THIRD-PARTY.md) and the bundled notices. The complete provenance and licence audit remains unfinished.

---

<p align="center"><strong>Small games. Big grins. Sweetcorn Arcade.</strong></p>
