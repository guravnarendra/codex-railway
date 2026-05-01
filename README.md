# Railway-Compatible Ubuntu Browser Desktop

This repo is the closest Railway-compatible version of a VPS-like Ubuntu desktop.

Important:

- This **can run on Railway**
- This is **not a true VPS or VM**
- Railway runs **containers**, not virtual machines
- So this gives you a **browser-based Ubuntu desktop environment**, not full VM behavior

## What this is

This project uses a Docker image that provides:

- Ubuntu-based desktop environment
- XFCE GUI
- Browser access through a web desktop
- Persistent user data through a Railway Volume

This feels similar to a lightweight remote Ubuntu machine in the browser, but under the hood it is still just one container.

## What Railway is doing

When you deploy this repo on Railway:

1. Railway pulls the GitHub repo
2. Railway sees the `Dockerfile`
3. Railway builds the container image
4. Railway runs it as a service
5. Railway maps a public domain to the service port
6. You open the desktop in your browser

## Tech stack

- Railway service
- Dockerfile deployment
- [`lscr.io/linuxserver/webtop:ubuntu-xfce`](https://docs.linuxserver.io/images/docker-webtop/)
- Ubuntu XFCE desktop
- Built-in browser desktop / noVNC stack from the base image
- Railway Volume mounted at `/config`

## What you get

- Ubuntu-like desktop in browser
- Ability to install some packages into the image at build time
- Persistent home/config data if stored in `/config`
- Public HTTPS access through Railway domain

## What you do not get

- A real VM
- Full systemd or host init control
- Kernel-level access
- Full VPS semantics
- Machine persistence outside the mounted volume

## Files

- `Dockerfile` - Railway build image
- `README.md` - deployment instructions

## Recommended Railway settings

For decent usability:

- RAM: at least `2 GB`
- Better RAM: `4 GB`
- vCPU: at least `1`
- Better vCPU: `2`
- Volume: at least `5 GB`

Recommended environment variables:

- `CUSTOM_USER=ubuntu`
- `PASSWORD=your-strong-password`
- `TZ=Asia/Kolkata`
- `TITLE=Ubuntu Desktop on Railway`
- `PORT=3000`
- `RAILWAY_SHM_SIZE_BYTES=1073741824`

Optional if volume permissions are awkward:

- `RAILWAY_RUN_UID=0`

## How to deploy on Railway from GitHub

### 1. Push this repo to GitHub

Commit and push this repository to your GitHub account.

### 2. Create a Railway project

In Railway:

1. Create a new project
2. Add a new service
3. Choose `Deploy from GitHub repo`
4. Select this repository

### 3. Let Railway build the Dockerfile

Railway will automatically detect the `Dockerfile` and build from it.

### 4. Add environment variables

In the Railway service variables, set:

- `CUSTOM_USER=ubuntu`
- `PASSWORD=your-strong-password`
- `TZ=Asia/Kolkata`
- `TITLE=Ubuntu Desktop on Railway`
- `PORT=3000`
- `RAILWAY_SHM_SIZE_BYTES=1073741824`

### 5. Add persistent storage

Attach a Railway Volume and mount it to:

```text
/config
```

This is important because the desktop image stores user config and persistent state there.

### 6. Generate a Railway domain

In Railway service networking:

1. Generate a public domain
2. Make sure the target port is `3000`

### 7. Redeploy

Redeploy the service after adding the variables and volume.

### 8. Open the desktop

Open the generated Railway domain in your browser.

## Default ports

This image exposes:

- `3000` for HTTP desktop access
- `3001` for HTTPS desktop access inside the container

For Railway, the simplest setup is to expose port `3000` and let Railway handle public HTTPS at the edge.

## How persistence works

Only data inside the mounted Railway Volume persists across restarts and redeploys.

For this image, use:

```text
/config
```

If something writes outside `/config`, it may disappear on rebuild or restart.

## Installing more apps

To add more default apps, edit the `apt-get install` line in the `Dockerfile`, then push again.

Example additions:

- `firefox`
- `chromium`
- `tmux`
- `build-essential`

Note:

- Bigger images take longer to build
- More apps mean more RAM and CPU usage

## Production reality

This is the strongest honest wording:

- It is **Railway-compatible**
- It is **Ubuntu desktop in browser**
- It is **VPS-like for some use cases**
- It is **not a real full production VPS**

If you need an actual production VPS or VM, use:

- Hetzner
- DigitalOcean
- Vultr
- AWS EC2
- GCP Compute Engine
- Azure VM

## Best use cases on Railway

This setup is reasonable for:

- Browser-accessible Linux workspace
- Demo desktop
- Internal tooling UI
- Temporary development environment
- Lightweight remote admin workspace

## Bad use cases on Railway

Do not treat this like:

- full enterprise VPS hosting
- kernel-sensitive workloads
- heavy multi-user desktop hosting
- long-lived machine-level infrastructure

## Suggested next step

Deploy this as-is first. Once it opens correctly on Railway, then add the extra apps you actually want.
