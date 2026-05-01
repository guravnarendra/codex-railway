#!/bin/bash
set -e

echo "========================================="
echo "  Browser VM — Starting up..."
echo "========================================="

# ── Resolve PORT (Railway injects $PORT, default 8080) ───────────────────────
PORT=${PORT:-8080}
VNC_PASSWORD=${VNC_PASSWORD:-changeme123}
VNC_RESOLUTION=${VNC_RESOLUTION:-1280x720}

echo "[INFO] Port: $PORT"
echo "[INFO] Resolution: $VNC_RESOLUTION"

# ── Update nginx to use correct port ─────────────────────────────────────────
sed -i "s/listen 8080;/listen $PORT;/" /etc/nginx/nginx.conf

# ── Create /data if it doesn't exist (volume mount) ──────────────────────────
mkdir -p /data
chown vuser:vuser /data

# ── Set up VNC password ───────────────────────────────────────────────────────
mkdir -p /home/vuser/.vnc
echo "$VNC_PASSWORD" | vncpasswd -f > /home/vuser/.vnc/passwd
chmod 600 /home/vuser/.vnc/passwd
chown -R vuser:vuser /home/vuser/.vnc

# ── Configure XFCE to autostart key apps ─────────────────────────────────────
mkdir -p /home/vuser/.config/xfce4/xfconf/xfce-perchannel-xml
cat > /home/vuser/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="Default"/>
    <property name="title_font" type="string" value="Sans Bold 9"/>
  </property>
</channel>
EOF
chown -R vuser:vuser /home/vuser/.config

# ── Build the landing page ────────────────────────────────────────────────────
mkdir -p /var/www/html/static
cat > /var/www/html/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Browser VM — Dashboard</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap');
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Inter', sans-serif;
      background: #0d0d0f;
      color: #e2e8f0;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 2rem;
    }
    h1 {
      font-size: 2.5rem;
      font-weight: 700;
      background: linear-gradient(135deg, #7c3aed, #3b82f6, #06b6d4);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }
    p.subtitle {
      color: #64748b;
      font-size: 1rem;
      margin-top: -1rem;
    }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
      gap: 1.5rem;
      width: 100%;
      max-width: 900px;
      padding: 0 1rem;
    }
    .card {
      background: rgba(255,255,255,0.04);
      border: 1px solid rgba(255,255,255,0.08);
      border-radius: 1rem;
      padding: 2rem;
      text-decoration: none;
      color: inherit;
      transition: all 0.25s ease;
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
      backdrop-filter: blur(12px);
    }
    .card:hover {
      background: rgba(255,255,255,0.08);
      border-color: rgba(124,58,237,0.5);
      transform: translateY(-4px);
      box-shadow: 0 20px 40px rgba(124,58,237,0.15);
    }
    .card .icon { font-size: 2.5rem; }
    .card h2 { font-size: 1.25rem; font-weight: 600; }
    .card p { color: #64748b; font-size: 0.875rem; line-height: 1.5; }
    .badge {
      display: inline-block;
      background: rgba(124,58,237,0.2);
      color: #a78bfa;
      border-radius: 9999px;
      padding: 0.2rem 0.75rem;
      font-size: 0.75rem;
      font-weight: 600;
      width: fit-content;
    }
    footer { color: #334155; font-size: 0.8rem; }
  </style>
</head>
<body>
  <div style="text-align:center">
    <h1>☁️ Browser VM</h1>
    <p class="subtitle">Your Linux environment in the cloud</p>
  </div>

  <div class="grid">
    <a class="card" href="/desktop/" target="_blank">
      <span class="icon">🖥️</span>
      <h2>Linux Desktop</h2>
      <p>Full XFCE4 GUI — file manager, apps, and more.</p>
      <span class="badge">noVNC</span>
    </a>
    <a class="card" href="/terminal/" target="_blank">
      <span class="icon">💻</span>
      <h2>Web Terminal</h2>
      <p>Full bash shell. Run commands, scripts, and tools.</p>
      <span class="badge">ttyd</span>
    </a>
    <div class="card">
      <span class="icon">💾</span>
      <h2>Persistent Storage</h2>
      <p>Files saved at <code>/data</code> survive restarts.</p>
      <span class="badge">Railway Volume</span>
    </div>
    <div class="card">
      <span class="icon">🗄️</span>
      <h2>PostgreSQL</h2>
      <p>Use <code>$DATABASE_URL</code> in terminal to connect.</p>
      <span class="badge">Railway DB</span>
    </div>
  </div>

  <footer>Ubuntu 22.04 LTS · XFCE4 · TigerVNC · noVNC · ttyd</footer>
</body>
</html>
HTMLEOF

echo "[INFO] Landing page created."

# ── Start Xvfb (virtual framebuffer) ─────────────────────────────────────────
echo "[INFO] Starting Xvfb..."
Xvfb :1 -screen 0 ${VNC_RESOLUTION}x${VNC_COL_DEPTH:-24} -ac +extension GLX +render -noreset &
XVFB_PID=$!
sleep 2

# ── Start VNC server ──────────────────────────────────────────────────────────
echo "[INFO] Starting TigerVNC..."
su -c "vncserver :1 -geometry ${VNC_RESOLUTION} -depth ${VNC_COL_DEPTH:-24} -localhost no -passwd /home/vuser/.vnc/passwd" vuser
sleep 2

# ── Start XFCE4 desktop ───────────────────────────────────────────────────────
echo "[INFO] Starting XFCE4..."
su -c "DISPLAY=:1 startxfce4 &" vuser &
sleep 3

# ── Start noVNC websockify bridge ─────────────────────────────────────────────
echo "[INFO] Starting noVNC..."
websockify --web=/usr/share/novnc/ --wrap-mode=ignore 6080 localhost:5901 &
sleep 1

# ── Start ttyd web terminal ───────────────────────────────────────────────────
echo "[INFO] Starting ttyd..."
ttyd \
  --port 7681 \
  --writable \
  --base-path /terminal \
  bash &
sleep 1

# ── Start Nginx ───────────────────────────────────────────────────────────────
echo "[INFO] Starting Nginx on port $PORT..."
nginx

echo "========================================="
echo "  Browser VM is READY on port $PORT"
echo "  Desktop  → /desktop/"
echo "  Terminal → /terminal/"
echo "========================================="

# ── Keep container alive ──────────────────────────────────────────────────────
wait
