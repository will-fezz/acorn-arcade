# Sweetcorn Arcade 2026.11.12 — automatic game catalogue recovery

When the phone requests a new game or a newer game version than the console's cached signed catalogue, the console automatically refreshes that catalogue while awake and idle, then resumes the exact same request. You no longer need to open More games → Look for games to recover this case.

The request remains pending during catalogue checks. It is not falsely marked failed or installed, and no game approval is created from unsigned phone data. All signed-catalogue, compatible-engine, exact-version, storage and download safeguards remain in force.

Temporary network failures use the existing 30-second backoff. Valid but old CDN responses get a bounded retry window (12 successful refreshes, spaced by that backoff), covering GitHub's usual five-minute cache. A version still unavailable afterwards is rejected clearly rather than retried forever. Requests retain their original expiry.

Crash-interrupted commands can wait safely for the catalogue after reboot without locking themselves into a storage-fault state. Command identity, replay protection and durable-intent handling remain in place. No pairing, save, settings or persisted-data layout changes.

Normal signed OTA preserves data. The factory image is first-install/recovery material, not the update route for an existing console.

Verification: 656 companion checks; 13,617 shell/UI checks and 4 rollback checks. Production ESP32-S3 build, image version/size, release-key signature and factory layout checked before staging. Physical-console behaviour is not verified until this new firmware is installed.

No game, artwork, app or server changes are included. Published release; physical-console verification follows installation.
