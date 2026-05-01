FROM ubuntu:22.04

# ── Environment ─────────────────────────────────────────────────────────────
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV VNC_RESOLUTION=1280x720
ENV VNC_COL_DEPTH=24
ENV HOME=/home/vuser
ENV USER=vuser

# ── System packages ──────────────────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Desktop
    xfce4 xfce4-goodies xfce4-terminal thunar mousepad \
    # VNC & display
    tigervnc-standalone-server tigervnc-common xvfb dbus-x11 \
    # noVNC
    novnc websockify python3 python3-pip \
    # Web terminal
    ttyd \
    # Web server
    nginx \
    # PHP for Adminer (PostgreSQL admin UI)
    php php-pgsql php-mbstring \
    # Utilities
    sudo curl wget git nano vim htop tree unzip zip jq \
    net-tools iputils-ping \
    postgresql-client \
    supervisor \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ── Node.js LTS ───────────────────────────────────────────────────────────────
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ── FileBrowser (web file manager) ───────────────────────────────────────────
RUN curl -fsSL https://github.com/filebrowser/filebrowser/releases/download/v2.27.0/linux-amd64-filebrowser.tar.gz \
    | tar -xz -C /usr/local/bin filebrowser \
    && chmod +x /usr/local/bin/filebrowser

# ── Adminer (PostgreSQL web admin) ───────────────────────────────────────────
RUN mkdir -p /var/www/adminer \
    && curl -fsSL https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
    -o /var/www/adminer/index.php

# ── Create non-root user ─────────────────────────────────────────────────────
RUN useradd -m -s /bin/bash vuser \
    && echo "vuser:vuser" | chpasswd \
    && usermod -aG sudo vuser \
    && echo "vuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ── noVNC symlink ─────────────────────────────────────────────────────────────
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# ── Persistent data directories ──────────────────────────────────────────────
RUN mkdir -p /data /var/www/html \
    && chown vuser:vuser /data

# ── Copy config files ─────────────────────────────────────────────────────────
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html /var/www/html/index.html
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8080
CMD ["/start.sh"]
