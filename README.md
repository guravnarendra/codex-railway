![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420?logo=ubuntu)
![Docker](https://img.shields.io/badge/Docker-Supported-blue?logo=docker)
![Desktop](https://img.shields.io/badge/GUI-XFCE4%20Desktop-blue?logo=linux)

# Ubuntu Desktop on Railway

A full **XFCE4 graphical desktop** running on Railway, accessible directly from your browser via **noVNC** — no client software required.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/new)

## How It Works

```
Browser → noVNC (WebSocket on $PORT) → TigerVNC Server → XFCE4 Desktop
```

- **noVNC** — serves the VNC viewer as a web app in your browser
- **TigerVNC** — the VNC server running inside the container
- **XFCE4** — lightweight, fast graphical desktop environment

## Access

After deployment, open your Railway-provided URL in any browser. You'll get a full Ubuntu desktop with:
- File manager
- XFCE4 Terminal
- Text editor
- And anything else you `apt install`

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `PORT` | Port noVNC listens on (set by Railway) | `8080` |
| `VNC_PASSWORD` | Password to protect the desktop | `changeme` |

> ⚠️ **Always set `VNC_PASSWORD`** to something strong before deploying.

## Pre-installed Software

- XFCE4 Desktop + Goodies
- TigerVNC Server
- noVNC (browser VNC client)
- git, curl, wget, python3, pip3
- nano, vim, neofetch

## Install More Software

Once connected to the desktop, open the terminal and run:
```bash
apt-get install -y <package>
```

## Notes

- Resolution defaults to **1280×800**. You can change it in `start.sh`.
- Data does not persist between restarts unless you attach a Railway Volume.
- The container runs as `root`.
