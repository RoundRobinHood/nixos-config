#!/usr/bin/env bash
set -euo pipefail

# Check for argument
if [ $# -lt 1 ]; then
  echo "Usage: $0 {switch|test|boot|dry-build}"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source and destination
SRC="$SCRIPT_DIR/"
DST="/etc/nixos/"

PRIOR_DIR="$PWD"

cd "$SRC"

[ -L "./result" ] && rm ./result
# Sync files
sudo rsync -av --exclude "result" --delete "$SRC" "$DST"

sudo chown -R root:root "$DST"

# Rebuilt (switch or test)
echo "Running nixos-rebuild $1..."
sudo nixos-rebuild "$1"

[ -L "./result" ] && rm ./result
cd "$PRIOR_DIR"
