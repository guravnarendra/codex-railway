#!/bin/bash
# NO set -e — we don't want one failing service to kill everything

echo "========================================="
echo "  Browser VM — Starting..."
echo "========================================="

PORT=${PORT:-8080}
VNC_PASSWORD=${VNC_PASSWORD:-changeme123}
VNC_RESOLUTION=${VNC_RESOLUTION:-1280x720}
VNC_COL_DEPTH=${VNC_COL_DEPTH:-24}

echo "[INFO] Port         : $PORT"
echo "[INFO] Resolution   : $VNC_RESOLUTION"

# ── Update nginx port dynamically ────────────────────────────────────────────
sed -i "s/listen 8080;/listen $PORT;/" /etc/nginx/nginx.conf

# ── Persistent data dir ───────────────────────────────────────────────────────
mkdir -p /data
chown vuser:vuser /data 2>/dev/null || true

# ── VNC password ──────────────────────────────────────────────────────────────
mkdir -p /home/vuser/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > /home/vuser/.vnc/passwd 2>/dev/null || true
chmod 600 /home/vuser/.vnc/passwd
chown -R vuser:vuser /home/vuser/.vnc

# ── XFCE config dir ───────────────────────────────────────────────────────────
mkdir -p /home/vuser/.config/xfce4/xfconf/xfce-perchannel-xml
chown -R vuser:vuser /home/vuser/.config

# ═══════════════════════════════════════════════════════════════════════════════
# START NGINX FIRST so Railway healthcheck passes immediately
# ═══════════════════════════════════════════════════════════════════════════════
echo "[INFO] Starting Nginx on port $PORT (early — for healthcheck)..."
nginx
echo "[INFO] Nginx started."

# ── 1. Xvfb (virtual display) ─────────────────────────────────────────────────
echo "[INFO] Starting Xvfb..."
Xvfb :1 -screen 0 ${VNC_RESOLUTION}x${VNC_COL_DEPTH} -ac +extension GLX +render -noreset &
sleep 3

# ── 2. TigerVNC ───────────────────────────────────────────────────────────────
echo "[INFO] Starting VNC server..."
su -c "vncserver :1 -geometry ${VNC_RESOLUTION} -depth ${VNC_COL_DEPTH} -localhost no -passwd /home/vuser/.vnc/passwd 2>/dev/null" vuser || \
  echo "[WARN] VNC server start failed — continuing anyway"
sleep 2

# ── 3. XFCE4 desktop ─────────────────────────────────────────────────────────
echo "[INFO] Starting XFCE4..."
su -c "DISPLAY=:1 startxfce4 &" vuser || echo "[WARN] XFCE4 start failed" &
sleep 3

# ── 4. noVNC websockify ───────────────────────────────────────────────────────
echo "[INFO] Starting noVNC..."
websockify --web=/usr/share/novnc/ --wrap-mode=ignore 6080 localhost:5901 &
sleep 1

# ── 5. ttyd web terminal ──────────────────────────────────────────────────────
echo "[INFO] Starting ttyd..."
ttyd --port 7681 --writable --base-path /terminal bash &
sleep 1

# ── 6. Adminer via PHP built-in HTTP server (port 9000) ──────────────────────
echo "[INFO] Starting Adminer (PHP)..."
php -S 127.0.0.1:9000 -t /var/www/adminer &
sleep 1

# ── 7. FileBrowser (file manager for /data) ───────────────────────────────────
echo "[INFO] Starting FileBrowser..."
# Init database on first run
filebrowser config init -d /data/.filebrowser.db 2>/dev/null || true
filebrowser config set -d /data/.filebrowser.db --auth.method=noauth 2>/dev/null || true
filebrowser \
  --port 8082 \
  --root /data \
  --baseurl /files \
  --database /data/.filebrowser.db \
  --log /dev/stdout &
sleep 1

echo "========================================="
echo "  Browser VM READY on port $PORT"
echo "  Dashboard  → /"
echo "  Desktop    → /desktop/"
echo "  Terminal   → /terminal/"
echo "  Files      → /files/"
echo "  Database   → /db/"
echo "========================================="

# ── Keep container alive ──────────────────────────────────────────────────────
wait
