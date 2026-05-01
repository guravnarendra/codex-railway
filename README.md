# Browser VM — Railway Deployment

A fully browser-accessible **Linux VM** running on Railway.

## Features

| Feature | Tool |
|---|---|
| Linux Desktop in Browser | noVNC + TigerVNC + XFCE4 |
| Web Terminal | ttyd |
| File Manager | Thunar (in desktop) |
| Persistent Files | Railway Volume at `/data` |
| Database | PostgreSQL (Railway plugin) |
| OS | Ubuntu 22.04 LTS |

## URLs (after deploy)

| Page | Path |
|---|---|
| Dashboard | `/` |
| Linux Desktop | `/desktop/` |
| Web Terminal | `/terminal/` |

## Environment Variables (set in Railway)

| Variable | Default | Description |
|---|---|---|
| `VNC_PASSWORD` | `changeme123` | VNC/desktop access password |
| `VNC_RESOLUTION` | `1280x720` | Desktop screen resolution |
| `PORT` | `8080` | Auto-set by Railway |
| `DATABASE_URL` | — | Auto-injected by Railway PostgreSQL plugin |

## Deploy to Railway

1. Push this repo to GitHub
2. Go to [railway.app](https://railway.app) → New Project → Deploy from GitHub
3. Add **PostgreSQL** plugin (+ New → Database → PostgreSQL)
4. Add a **Volume** → mount path `/data`
5. Set `VNC_PASSWORD` in environment variables
6. Deploy!

## Database Usage

Inside the web terminal:
```bash
psql $DATABASE_URL
```

## Persistent Files

All files under `/data` persist across restarts:
```bash
ls /data
cp myfile.txt /data/
```
