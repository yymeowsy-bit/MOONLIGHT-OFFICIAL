#!/usr/bin/env bash
# Launch Moonlight.
#   ./run.sh          normal user (everything except raw packet capture)
#   ./run.sh --root   relaunch through sudo -E so scapy can open raw sockets
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

PY="./.venv/bin/python"
[ -x "./.venv/bin/moonlight-python" ] && PY="./.venv/bin/moonlight-python"
[ -x "$PY" ] || PY="python3"

if [ "${1:-}" = "--root" ]; then
  shift
  exec sudo -E "$PY" main.py "$@"
fi

exec "$PY" main.py "$@"
