#!/usr/bin/env bash
# Install a LaunchDaemon that keeps macOS's AWDL interface disabled. AWDL backs
# AirDrop/Handoff/Sidecar and time-slices the Wi-Fi radio off-channel, causing
# latency spikes; this trades those features for a steady connection.
# Idempotent and self-contained (needs sudo); always exits 0 so install.sh's
# `set -e` never aborts if sudo is unavailable.
set -u

PLIST=com.local.disableawdl.plist
SRC="$(cd "$(dirname "$0")/.." && pwd)/config/$PLIST"
DEST="/Library/LaunchDaemons/$PLIST"

# Already installed and unchanged → nothing to do.
if cmp -s "$SRC" "$DEST"; then
    exit 0
fi

if ! sudo -n true 2>/dev/null && ! sudo true 2>/dev/null; then
    echo "disable-awdl: skipped (needs sudo)."
    exit 0
fi

sudo cp "$SRC" "$DEST" || { echo "disable-awdl: copy failed."; exit 0; }
sudo chown root:wheel "$DEST"
sudo chmod 644 "$DEST"
sudo launchctl bootout system "$DEST" 2>/dev/null || true
sudo launchctl bootstrap system "$DEST" 2>/dev/null || true
echo "disable-awdl: installed and loaded."
exit 0
