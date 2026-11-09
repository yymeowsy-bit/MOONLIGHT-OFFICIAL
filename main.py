#!/usr/bin/env python3
"""Moonlight - network analysis suite for Linux.

Run it:
    python3 main.py                # normal use
    sudo -E python3 main.py        # packet capture (raw sockets need root)
"""

from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from PyQt6.QtWidgets import QApplication

from moonlight.app import MoonlightWindow, app_icon
from moonlight.config import APP_VERSION, Config, ensure_dirs
from moonlight.theme import ACCENTS, apply_theme, theme


def main() -> int:
    if "--version" in sys.argv:
        print(f"MoonLight {APP_VERSION}")
        return 0

    ensure_dirs()

    app = QApplication(sys.argv)
    app.setApplicationName("MoonLight")
    app.setApplicationDisplayName("MoonLight")
    app.setDesktopFileName("moonlight")

    config = Config()
    th = theme()
    accent = config.get("appearance", "accent", "Purple")
    th.accent = ACCENTS.get(accent, ACCENTS["Purple"])
    th.panel_alpha = max(0.1, min(1.0, int(config.get("appearance", "panel_opacity", 72)) / 100.0))
    apply_theme(app, th)
    app.setWindowIcon(app_icon())

    window = MoonlightWindow(config)
    window.show()
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
