# App artwork

Public cosmetic PNGs keyed by theme/game. The iOS app refreshes the manifest on foreground (at most every five minutes) and caches hash-verified images for offline use. Unknown games and unavailable images use generic symbols.

For every catalogue or pack release, run `python3 tools/generate-app-artwork.py .` with Pillow installed and the catalogue packs present. Publish generated app-artwork files with that release. No app build or signing private key is needed for artwork changes. This does not install console games.
