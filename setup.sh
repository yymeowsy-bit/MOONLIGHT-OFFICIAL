#!/usr/bin/env bash
# MoonLight setup — grants cap_net_raw to python3 so live capture works without sudo
# Run this ONCE:  sudo ./setup.sh

set -e

PYTHON=$(readlink -f $(which python3))
echo "Python binary: $PYTHON"

if [[ $EUID -ne 0 ]]; then
    echo "Re-running with sudo…"
    exec sudo "$0" "$@"
fi

echo "Setting cap_net_raw+eip on $PYTHON …"
setcap cap_net_raw+eip "$PYTHON"

echo ""
echo "Done! Verifying:"
getcap "$PYTHON"
echo ""
echo "You can now run MoonLight and capture packets without root:"
echo "  python3 moonlight.py"
