#!/usr/bin/env bash
# Moonlight installer: system Qt libraries + a local virtualenv.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$HERE"

echo "== Moonlight setup =="
echo "Detecting distribution..."

install_system_packages() {
  if command -v pacman >/dev/null 2>&1; then
    echo "-> Arch / Manjaro / EndeavourOS"
    sudo pacman -S --needed --noconfirm \
      python python-pip python-virtualenv \
      qt6-multimedia qt6-multimedia-ffmpeg \
      libpulse ffmpeg libxcb libxkbcommon-x11 ttf-liberation
  elif command -v dnf >/dev/null 2>&1; then
    echo "-> Fedora / RHEL / Nobara"
    sudo dnf install -y \
      python3 python3-pip python3-virtualenv \
      qt6-qtmultimedia qt6-qtmultimedia-devel \
      pulseaudio-libs ffmpeg-free xcb-util-cursor libxkbcommon-x11
  elif command -v zypper >/dev/null 2>&1; then
    echo "-> openSUSE"
    sudo zypper install -y python3 python3-pip python3-virtualenv \
      libQt6Multimedia6 libqt6-qtmultimedia6 pulseaudio ffmpeg libxcb-cursor0
  elif command -v apt-get >/dev/null 2>&1; then
    echo "-> Debian / Ubuntu / Mint / Pop!_OS"
    sudo apt-get update
    sudo apt-get install -y \
      python3 python3-venv python3-pip \
      libgl1 libegl1 libxkbcommon-x11-0 libxcb-cursor0 libxcb-icccm4 \
      libxcb-image0 libxcb-keysyms1 libxcb-randr0 libxcb-render-util0 \
      libxcb-shape0 libxcb-xinerama0 libpulse0 ffmpeg
    # libasound2 is libasound2t64 on Ubuntu 24.04+
    sudo apt-get install -y libasound2t64 2>/dev/null || sudo apt-get install -y libasound2 2>/dev/null || true
  else
    echo "!! Unknown package manager. Install python3 + PyQt6 system libs manually."
  fi
}

install_system_packages

echo
echo "== Python environment =="
if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi
./.venv/bin/pip install --upgrade pip >/dev/null
./.venv/bin/pip install -r requirements.txt

echo
echo "== Desktop entry =="
APPS="$HOME/.local/share/applications"
mkdir -p "$APPS"
sed "s|__MOONLIGHT_DIR__|$HERE|g" packaging/moonlight.desktop > "$APPS/moonlight.desktop"
echo "installed $APPS/moonlight.desktop"

# Refresh common desktop-menu/icon caches when the desktop provides them.
update-desktop-database "$APPS" >/dev/null 2>&1 || true
gtk-update-icon-cache -f -t "$HOME/.local/share/icons" >/dev/null 2>&1 || true

echo
echo "Done."
echo "  start normally : ./run.sh"
echo "  with capture   : ./run.sh --root"
