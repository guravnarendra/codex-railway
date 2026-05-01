#!/bin/bash
set -e

VNC_PORT=5901
DISPLAY_NUM=1
VNC_PASSWORD=${VNC_PASSWORD:-password}
PORT=${PORT:-8080}

# --- Setup VNC password ---
mkdir -p /root/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd

# --- Write XFCE4 startup config ---
cat > /root/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XDG_RUNTIME_DIR=/tmp/runtime-root
mkdir -p $XDG_RUNTIME_DIR
chmod 700 $XDG_RUNTIME_DIR
exec startxfce4
EOF
chmod +x /root/.vnc/xstartup

# --- Kill any stale VNC locks ---
rm -f /tmp/.X${DISPLAY_NUM}-lock /tmp/.X11-unix/X${DISPLAY_NUM}

# --- Start TigerVNC server ---
echo "[*] Starting VNC server on :${DISPLAY_NUM} (port ${VNC_PORT})..."
vncserver :${DISPLAY_NUM} \
  -geometry 1280x800 \
  -depth 24 \
  -rfbport ${VNC_PORT} \
  -rfbauth /root/.vnc/passwd \
  -localhost no \
  -fg &

sleep 3

# --- Start noVNC websocket proxy ---
echo "[*] Starting noVNC on port ${PORT}..."
/opt/noVNC/utils/novnc_proxy \
  --vnc localhost:${VNC_PORT} \
  --listen ${PORT} \
  --web /opt/noVNC &

wait
