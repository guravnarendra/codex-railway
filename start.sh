#!/bin/bash
set -e

echo "========================================="
echo "  Browser VM — Starting..."
echo "========================================="

PORT=${PORT:-8080}
VNC_PASSWORD=${VNC_PASSWORD:-changeme123}
VNC_RESOLUTION=${VNC_RESOLUTION:-1280x720}
VNC_COL_DEPTH=${VNC_COL_DEPTH:-24}

echo "[INFO] Port         : $PORT"
echo "[INFO] Resolution   : $VNC_RESOLUTION"

# ── Dynamic port for nginx ────────────────────────────────────────────────────
sed -i "s/listen 8080;/listen $PORT;/" /etc/nginx/nginx.conf

# ── Persistent data dir ───────────────────────────────────────────────────────
mkdir -p /data
chown vuser:vuser /data

# ── VNC password ──────────────────────────────────────────────────────────────
mkdir -p /home/vuser/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > /home/vuser/.vnc/passwd
chmod 600 /home/vuser/.vnc/passwd
chown -R vuser:vuser /home/vuser/.vnc

# ── XFCE config ───────────────────────────────────────────────────────────────
mkdir -p /home/vuser/.config/xfce4/xfconf/xfce-perchannel-xml
chown -R vuser:vuser /home/vuser/.config

# ── 1. Xvfb (virtual display) ─────────────────────────────────────────────────
echo "[INFO] Starting Xvfb..."
Xvfb :1 -screen 0 ${VNC_RESOLUTION}x${VNC_COL_DEPTH} -ac +extension GLX +render -noreset &
sleep 2

# ── 2. TigerVNC ───────────────────────────────────────────────────────────────
echo "[INFO] Starting VNC server..."
su -c "vncserver :1 -geometry ${VNC_RESOLUTION} -depth ${VNC_COL_DEPTH} -localhost no -passwd /home/vuser/.vnc/passwd" vuser
sleep 2

# ── 3. XFCE4 desktop ─────────────────────────────────────────────────────────
echo "[INFO] Starting XFCE4..."
su -c "DISPLAY=:1 startxfce4 &" vuser &
sleep 3

# ── 4. noVNC websockify ───────────────────────────────────────────────────────
echo "[INFO] Starting noVNC..."
websockify --web=/usr/share/novnc/ --wrap-mode=ignore 6080 localhost:5901 &
sleep 1

# ── 5. ttyd web terminal ──────────────────────────────────────────────────────
echo "[INFO] Starting ttyd..."
ttyd --port 7681 --writable --base-path /terminal bash &
sleep 1

# ── 6. PHP-FPM for Adminer ───────────────────────────────────────────────────
echo "[INFO] Starting PHP FastCGI for Adminer..."
php -S 127.0.0.1:9000 -t /var/www/adminer /var/www/adminer/index.php &
sleep 1

# ── 7. FileBrowser ───────────────────────────────────────────────────────────
echo "[INFO] Starting FileBrowser..."
filebrowser \
  --port 8082 \
  --root /data \
  --baseurl /files \
  --noauth \
  --log /dev/stdout &
sleep 1

# ── 8. Nginx ─────────────────────────────────────────────────────────────────
echo "[INFO] Starting Nginx on port $PORT..."
nginx

echo "========================================="
echo "  Browser VM READY on port $PORT"
echo "  Dashboard  → /"
echo "  Desktop    → /desktop/"
echo "  Terminal   → /terminal/"
echo "  Files      → /files/"
echo "  Database   → /db/"
echo "========================================="

wait
