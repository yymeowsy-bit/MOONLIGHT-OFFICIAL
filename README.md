# MoonLight v1.0

**Linux network guardian — Wireshark-style live packet capture, DDoS detection, and device monitoring.**

![Platform](https://img.shields.io/badge/platform-Linux%20x86__64-blue)
![Python](https://img.shields.io/badge/python-3.14-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Features

- **Live packet capture** — Wireshark-style table with BPF capture filters and display filters
- **Protocol coloring** — TCP, UDP, DNS, HTTPS, TLS, SSH, ICMP, ARP, DHCP and more
- **Packet inspector** — click any packet to see full layer dissection tree + hex dump
- **DDoS detection** — real-time SYN flood, ICMP flood, ARP spoofing, retransmit storms from kernel counters
- **Network devices** — auto-discover every device on your LAN, click any device to see its live connections
- **WiFi scanner** — live scan via nmcli, evil-twin detection (duplicate SSIDs flagged)
- **Display filter** — Wireshark-compatible syntax: `ip.src == x.x.x.x`, `tcp.port == 443`, `frame.len > 500`
- **Streamer mode** — one toggle hides all IPs, MACs, and SSIDs from the entire UI
- **Custom backgrounds** — image (JPG/PNG/WebP) or looping video (.mp4) as UI background
- **Music player** — docked bottom bar, supports MP3 / FLAC / WAV / OGG
- **Theme presets** — Midnight Glass, Neon Aurora, Minimal Dark, Translucent Cyber + export/import

---

## Requirements

| Requirement | Version |
|---|---|
| Linux x86_64 | Any modern distro |
| Python | 3.14 |
| PyQt6 | >= 6.4 |
| scapy | >= 2.5 |
| psutil | >= 5.9 |

Install dependencies:

```bash
pip install -r requirements.txt
```

---

## Installation

### 1. Download

Download `moonlight_v1.0_linux_x86_64.zip` from the [Releases](https://github.com/vexisy/moonlight/releases) page and extract it:

```bash
unzip moonlight_v1.0_linux_x86_64.zip
cd moonlight_v1.0_linux_x86_64
```

### 2. Install Python dependencies

```bash
pip install -r requirements.txt
```

Or using pipx / a virtual environment if your distro restricts system pip:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### 3. Enable live packet capture (one-time setup)

MoonLight needs `cap_net_raw` to capture packets without running as root.  
Run this **once** — you will never need `sudo` again after this:

```bash
sudo ./setup.sh
```

This runs a single `setcap` command on your Python binary. Nothing is installed system-wide.

### 4. Run

```bash
./run.sh
```

Or directly:

```bash
python3 moonlight_run.py
```

---

## Quick Start

1. Open MoonLight → go to **Capture**
2. Select your network interface (e.g. `removed for security reasons`)
3. Hit **Start** — packets appear immediately
4. Use the display filter bar: `tcp`, `dns`, `ip.addr == 192.168.1.1`, etc.
5. Click any row to see the full packet breakdown and hex dump

---

## Display Filter Syntax

| Expression | Matches |
|---|---|
| `tcp` | all TCP packets |
| `dns` | DNS queries and responses |
| `https` | port 443 traffic |
| `ip.src == 192.168.1.5` | specific source IP |
| `ip.addr == 192.168.1.5` | source or destination |
| `tcp.port == 443` | specific port |
| `frame.len > 500` | packets over 500 bytes |
| `tcp and 443` | combined AND filter |
| `dns or icmp` | combined OR filter |

---

## Streamer Mode

Go to **Settings → Streamer Mode** and flip the toggle before going live.

All IPs become `***.***.***.***`, MACs become `**:**:**:**:**:**`, SSIDs become `****************`. Nothing is logged or hidden — purely a display mask. Toggle it off and everything comes back.

---

## Troubleshooting

**Capture page shows "cap_net_raw required"**  
Run `sudo ./setup.sh` once. This grants the capability to your Python binary permanently.

**No devices showing on the Devices page**  
The app reads from `/proc/net/arp`. Make sure you are connected to a network. Devices appear when there is ARP traffic (usually within a few seconds of the machine being active).

**Video background doesn't play**  
Requires PyQt6 with multimedia support and FFmpeg. On Arch: `pacman -S gst-plugins-good ffmpeg`. On Ubuntu: `apt install python3-pyqt6 python3-pyqt6.qtmultimedia`.

**App crashes on launch**  
Make sure you are running Python **3.14 x86_64**. The compiled `.so` is tied to this specific Python version and architecture.

```bash
python3 --version  # must show Python 3.14.x
uname -m           # must show x86_64
```

---

## Building from Source

If you want to build from the Python source yourself:

```bash
git clone https://github.com/vexisy/moonlight
cd moonlight
python3 build_release.py        # full build (~2 min first time)
python3 build_release.py --fast  # relink only (~90s after first build)
```

Requires: `cython`, `gcc`, `python3-dev`

```bash
pip install cython
```

---

## Platform Support

| Distro | Status |
|---|---|
| Arch Linux | ✓ Tested |
| Ubuntu 22.04+ | ✓ Supported |
| Fedora 38+ | ✓ Supported |
| Linux Mint | ✓ Supported |
| Debian 12+ | ✓ Supported |

> Windows and macOS are **not** supported. This tool uses Linux-specific interfaces (`/proc/net`, `cap_net_raw`, `nmcli`).

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

*Released by **vexisy**  •  MoonLight v1.0*
