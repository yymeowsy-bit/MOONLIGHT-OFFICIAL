#!/usr/bin/env bash
# Give only Moonlight's dedicated Python interpreter packet-capture capabilities.
# This avoids granting CAP_NET_RAW to the system Python executable.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"
PY_VENV="$HERE/.venv/bin/python"
PY_CAP="$HERE/.venv/bin/moonlight-python"

if [ ! -x "$PY_VENV" ]; then
  echo "MoonLight is not installed yet. Run ./install.sh first." >&2
  exit 1
fi
if ! command -v setcap >/dev/null 2>&1; then
  echo "setcap is missing. On Arch install it with: sudo pacman -S libcap" >&2
  exit 1
fi

REAL_PY="$(readlink -f "$PY_VENV")"
# A copied interpreter gets its own file capability; the system interpreter stays unchanged.
if [ ! -e "$PY_CAP" ] || [ "$REAL_PY" -nt "$PY_CAP" ]; then
  cp --reflink=auto "$REAL_PY" "$PY_CAP"
  chmod 0755 "$PY_CAP"
fi

# CAP_NET_RAW is what AF_PACKET/scapy needs for ordinary packet capture.
sudo setcap cap_net_raw=eip "$PY_CAP"

# Uncomment the following instead only if your desktop/NIC requires promiscuous-mode
# administration. CAP_NET_ADMIN is broader than needed for most captures.
# sudo setcap cap_net_raw,cap_net_admin=eip "$PY_CAP"

echo "Enabled packet capture capabilities for: $PY_CAP"
getcap "$PY_CAP"
echo "Now start MoonLight normally with: ./run.sh"
