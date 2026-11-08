#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ $EUID -ne 0 ]]; then
    echo "MoonLight v1.0  —  run  sudo ./setup.sh  once to enable live capture"
fi
python3 "$SCRIPT_DIR/moonlight_run.py"
