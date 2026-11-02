<p align="center"><img src="assets/acorn-mascot.png" width="240" alt="Acorn Arcade cartoon acorn mascot"></p>

# Acorn Arcade: console game library (repo will-fezz/acorn-arcade; not pushed yet)

Layout: `catalogue.json` + `catalogue.json.sig` (signed list), `packs/*.gpk` (signed packs),
`src/<game>/` (rules + manifest), `keys/` (public halves of the test key and the real release key), `licences/` (Sniglet and Nunito, SIL OFL 1.1: the firmware contains both fonts).

Build + sign (private keys are in `~/.openclaw/secrets/`: `game-pack-release-ed25519.pem` for packs, `game-pack-test-ed25519.pem` only as the bridge from firmware 2. Never commit them):

    venv/bin/python -I tools/packs/gpk.py build game-library/src/snake art game-library/packs/snake-1.gpk <key>
    venv/bin/python -I tools/packs/gpk.py catalogue game-library <key> https://raw.githubusercontent.com/will-fezz/acorn-arcade/main

The catalogue is already signed for that URL. Changing the URL base means re-signing, since the URL is
inside the signed file. Publishing is left to Eric: push this folder as the repo.
Delivery to the console, and why it has to come through this repo's `main` branch, is in the project README under "Reaching the console". `acorn-firmware/tools/stage_delivery.sh` builds the files.
Moving from the test key to the real one is in the project README, "Signing keys". Finish it before anyone but Will uses this: the key that signs is the key that ships code.
