#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY_CAP="$HERE/.venv/bin/moonlight-python"
if [ -e "$PY_CAP" ] && command -v setcap >/dev/null 2>&1; then
  sudo setcap -r "$PY_CAP"
  echo "Removed packet-capture capabilities from $PY_CAP"
else
  echo "No dedicated capability-enabled interpreter found."
fi
