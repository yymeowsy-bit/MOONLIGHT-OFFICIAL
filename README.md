# Moonlight

A Wireshark-style network suite for Linux with a proper GUI — packet capture, link
quality, WiFi detail, ARP/devices, threat heuristics, system info, firewall overview,
logs, a working music player and Discord Rich Presence.

Built with **PyQt6**, no external player binary required, and no fake data: every
number comes from `/proc`, `/sys`, `ip`, `nmcli`/`iw` or your own captured packets.

MoonLight uses the native Linux window frame. Its titlebar is supplied by your desktop
environment, so the normal minimize, maximize, close and drag behavior works correctly.

```
./run.sh            # normal use (everything except raw packet capture)
./run.sh --root     # sudo -E ... so scapy can open raw sockets
```

---

## 1. Install

```bash
cd moonlight
chmod +x install.sh run.sh
./install.sh          # system Qt libs + .venv with PyQt6, pypresence, scapy
./run.sh
```

`install.sh` handles Arch/Manjaro (`pacman`), Fedora/Nobara (`dnf`), openSUSE
(`zypper`) and Debian/Ubuntu/Mint (`apt`). It also writes
`~/.local/share/applications/moonlight.desktop` so Moonlight shows up in your app menu.
The menu entry is named **MoonLight** and points at the supplied transparent logo.

## Updates

MoonLight checks the official GitHub repository for a newer stable release. In Settings,
you can turn off **Automatically install updates when MoonLight starts** and/or turn off
**Restart MoonLight automatically after updating**. When automatic installation is off,
an available release appears in Settings as **New Release** with a **Download Now** button.
Updates are downloaded as ZIP assets, validated before installation, and applied by a
detached helper only after MoonLight has closed.

Manual install, if you prefer:

```bash
python3 -m venv .venv
./.venv/bin/pip install -r requirements.txt
./.venv/bin/python main.py
```

---

## 2. Folder structure — what goes where

Everything you can swap out lives in `assets/`. The code never breaks when a file is
missing: icons are drawn with QPainter, the logo is drawn as a crescent, the background
falls back to a gradient.

```
moonlight/
├── main.py                     # entry point (python3 main.py)
├── run.sh / install.sh         # launcher + installer
├── requirements.txt
├── packaging/
│   └── moonlight.desktop       # app-menu entry template
├── moonlight/                  # the application package
│   ├── app.py                  # main window, navigation, telemetry wiring
│   ├── config.py               # settings (~/.config/moonlight/config.json)
│   ├── theme.py                # palette, fonts, global stylesheet
│   ├── core/                   # no Qt widgets here, only data + logic
│   │   ├── audio.py            # music player engine (QtMultimedia)
│   │   ├── rpc.py              # Discord Rich Presence (id baked in, never shown)
│   │   ├── netif.py            # throughput, link quality, drops/errors
│   │   ├── wifi.py             # SSID/signal/channel + network scan
│   │   ├── capture.py          # scapy sniffer + pcap export
│   │   ├── threats.py          # port scan / ICMP flood / plain-text rules
│   │   ├── arp.py              # neighbour table, MAC conflicts
│   │   ├── firewall.py         # ufw / firewalld / nft / iptables status
│   │   ├── sysinfo.py          # CPU, RAM, disk, tools
│   │   ├── logs.py             # in-app event log + system log tail
│   │   └── util.py             # formatting + shell helpers
│   └── ui/
│       ├── widgets.py          # Card, StatTile, Sparkline, tables, toast
│       ├── icons.py            # vector icons (asset override aware)
│       ├── titlebar.py         # frameless title bar + moon mark
│       ├── sidebar.py          # navigation rail
│       ├── background.py       # gradient / image / looping video layer
│       ├── player.py           # music dock + playlist popup
│       └── pages/              # one file per tab
└── assets/
    ├── logos/                  # app icon + Discord rich presence art
    ├── icons/                  # optional PNG/SVG overrides for every icon
    ├── backgrounds/            # drop your wallpapers here
    ├── video/                  # drop your background videos here
    ├── fonts/                  # optional Inter / JetBrains Mono
    └── sounds/                 # reserved (UI feedback)
```

### 2.1 `assets/logos/` — the Gemini artwork goes here

| File | Size | Where it shows up |
|------|------|-------------------|
| `moon_512.png` | 512×512, transparent | Discord Rich Presence asset, store screenshots |
| `moon_256.png` | 256×256 | window icon, app menu, desktop entry |
| `moon_128.png` | 128×128 | sidebar / title bar on HiDPI |
| `moon_64.png` | 64×64 | small UI spots |
| `moon_32.png` | 32×32 | tray-sized |
| `moon.png` | 256×256 | generic fallback |
| `moonlight_logo.png` | 512×512, transparent | exact Discord asset key `moonlight_logo` |
| `moonlight.ico` | multi-size | Windows-compatible icon container |

Placeholder crescents are already there so nothing looks broken — **overwrite the same
filenames** and restart Moonlight. Keep them square with a transparent background.

### 2.2 `assets/icons/` — optional icon overrides

Every icon is drawn in code. If `assets/icons/<name>.png` (or `.svg`) exists, Moonlight
uses it instead. Valid names:

```
home  capture  network  wifi  arp  threats  stats  devices  system  firewall
logs  settings  play  pause  prev  next  volume  folder  image  video  moon
refresh  search  copy  trash  power  plus  check  download  list  minus
square  close
```

Recommended: 48×48 PNG (or 24×24 SVG), single colour `#e9e6f2`, transparent background.

### 2.3 `assets/backgrounds/` and `assets/video/`

Any file works — you pick them inside **Settings → Background**. Nothing needs to be
pre-placed, but you can park your favourites here:

* images: `.png .jpg .jpeg .webp .bmp`
* video: `.mp4 .webm .mkv .mov .avi` (H.264 MP4 is the safest; it loops automatically)

### 2.4 `assets/fonts/`

Drop `Inter*.ttf` and `JetBrainsMono*.ttf` here for the exact look from the screenshots.
Without them Moonlight uses your system sans/mono (still fine, just slightly different).

---

## 3. Discord Rich Presence

What people see on your profile:

```
Monitoring Network Traffic
Listening To <track name>
```

The Rich Presence also includes a **Download MoonLight** button linking to the official
repository: <https://github.com/yymeowsy-bit/MOONLIGHT-OFFICIAL>.

When nothing is playing it is just `Monitoring Network Traffic` + `Idle`.

Setup:

1. Create an application at <https://discord.com/developers/applications>.
2. Under **Rich Presence → Art Assets**, upload `assets/logos/moon_512.png` with the
   exact asset key **`moonlight_logo`** (that key is what the app requests).
3. Put your application id in `moonlight/core/rpc.py` — it is stored **obfuscated** in
   `_APP_ID_BLOB` (`base64(xor(id, 0x5A))`), not as plain text.
4. Discord desktop must be running. Toggle presence in **Settings → Discord**.

Privacy, as requested:

* the application id is never displayed in the UI, never written to the log, never in an
  error message, and there is no input field to change it at runtime;
* presence carries only the two lines above — no buttons, no timestamps, no IPs;
* if Discord is closed or the toggle is off, nothing is sent at all.

> Honest note: any client-side id can be recovered by someone who really wants to. The
> obfuscation stops casual snooping (grep, screenshots, log files), not a determined
> reverse-engineer. Keeping it out of the UI and logs is the part that actually matters.

To use your own application id, run:

```bash
python3 -c "import base64;print(base64.b64encode(bytes(ord(c)^0x5A for c in 'YOUR_ID')).decode())"
```

and paste the result into `_APP_ID_BLOB`.

---

## 4. Tabs

| Tab | What it does |
|-----|--------------|
| **Home** | `Welcome To MoonLight` hero, link quality gauge (Good/Fair/Poor/Terrible), drops & errors, live throughput graph, connection + session summary, quick actions |
| **Capture** | live packet list (time/src/dst/proto/len/info), BPF capture filter, substring display filter, auto-scroll, pcap export |
| **Network** | per-interface table (state, IPv4, MAC, MTU, speed, rates, drops, errors), routing table, DNS resolvers |
| **WiFi** | SSID/BSSID, signal dBm, quality gauge, band, channel, security, bitrate + scan of nearby networks |
| **ARP** | neighbour cache with gateway highlight and shared-MAC warnings |
| **Threats** | port-scan, ICMP-flood and plain-text-service detections with severity + hit counts |
| **Statistics** | protocol mix, top talkers, top destination ports, throughput chart |
| **Devices** | LAN devices with reverse-DNS names, first/last seen, conflicts |
| **System** | host, distro, kernel, CPU, memory, disk, runtime versions, detected tools |
| **Firewall** | backend + status + readable rules, copyable privileged command (read-only by design) |
| **Logs** | Moonlight's own event log (filter + export) and a kernel log tail |
| **Settings** | background image **and** video, image/video visibility, panel opacity, accent colour, music library, Discord toggles, capture limits, reset |

### Music player

* **Add files** (the `+` button), **Add folder** (playlist popup), or drag & drop audio
  onto the dock — `.mp3 .flac .wav .ogg .m4a .aac .opus .wma` all work.
* Play/pause, previous/next, seek bar, volume, playlist with per-track removal.
* Playlist and volume persist between runs.
* Titles come from ID3/metadata when present, otherwise the filename.

### Background image / video

Settings → Background: pick **Gradient**, **Image** or **Video**, choose a file, then set
**visibility** (how strongly the media shows) and **panel opacity** (how transparent the
sidebar, cards and dock are). Video loops forever, muted, and keeps the last frame
scaled to the window. Everything is stored in the config and restored on launch.

---

## 5. Permissions

| Feature | Needs root? |
|---------|-------------|
| Everything except Capture | no |
| Capture (raw sockets via scapy) | **yes** — `./run.sh --root` |
| Firewall *rules* (not status) | yes — Moonlight only shows you the command |

### Capture without running MoonLight as root

The recommended option is the included dedicated-interpreter setup. It copies the venv
Python executable, gives **only that copy** `CAP_NET_RAW`, and makes `run.sh` use it:

```bash
sudo pacman -S libcap                 # Arch, if setcap is not installed
./enable-capture-capabilities.sh
./run.sh                              # now capture as your normal user
getcap .venv/bin/moonlight-python
```

You should see `cap_net_raw=eip`. This is safer than applying capabilities to
`/usr/bin/python`, which would give raw-socket privileges to unrelated Python programs.
If a particular adapter requires promiscuous-mode administration, edit the script's
commented `setcap` line to use `cap_net_raw,cap_net_admin=eip`; `CAP_NET_ADMIN` is broader
and should only be enabled when `CAP_NET_RAW` alone is insufficient. To undo it:

```bash
./disable-capture-capabilities.sh
```

The fallback remains `./run.sh --root`. File capabilities can be lost after recreating
`.venv`, so run the enable script again after reinstalling dependencies.

Interface counters, WiFi quality, ARP, routes and DNS all come from `/proc` and `/sys`,
so they work as a normal user.

---

## 6. Troubleshooting

**No sound, but the progress bar moves.** Moonlight checks for a running PulseAudio /
PipeWire socket before creating an audio device; if there is none (headless box, container)
it decodes silently instead of crashing. Install `pipewire-pulse` or `pulseaudio`.

**Video background is black.** The FFmpeg backend is missing. Arch: `qt6-multimedia-ffmpeg`,
Fedora: `qt6-qtmultimedia`, Debian/Ubuntu: `libqt6multimedia6` + `ffmpeg`.

**Capture says permission denied.** Start with `./run.sh --root`. On Wayland with some
compositors you may also need `sudo -E` so `XDG_RUNTIME_DIR` survives.

**No WiFi tab data.** `nmcli`/`iw` missing, or the adapter exposes no wireless
extensions. Install `networkmanager` and `iw`.

**Window looks unsharp on HiDPI.** Qt6 scales automatically; set
`QT_SCALE_FACTOR=1.25` if you want it bigger.

Config lives in `~/.config/moonlight/config.json`, logs in
`~/.config/moonlight/moonlight.log`. Delete the config file to start fresh.

---

## 7. Not included (say the word and it goes in)

Ideas I deliberately left out so I do not add things you did not ask for:

* packet detail tree (layer-by-layer decode of a selected packet)
* capture from a `.pcap` file instead of a live interface
* per-process traffic attribution (`ss`/`nethogs` style)
* tray icon with quick capture toggle
* global hotkeys (space = play/pause)
* speed-test tab
* vendor lookup for MAC addresses (needs an OUI database)
* multiple simultaneous captures
