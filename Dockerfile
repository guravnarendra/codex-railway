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
    # Desktop environment
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    thunar \
    mousepad \
    # VNC & display
    tigervnc-standalone-server \
    tigervnc-common \
    xvfb \
    dbus-x11 \
    # noVNC dependencies
    novnc \
    websockify \
    python3 \
    python3-pip \
    # Web terminal
    ttyd \
    # Web server
    nginx \
    # Utils & dev tools
    sudo \
    curl \
    wget \
    git \
    nano \
    vim \
    htop \
    tree \
    unzip \
    zip \
    jq \
    net-tools \
    iputils-ping \
    # Database client
    postgresql-client \
    # Process supervisor
    supervisor \
    # Node.js (LTS)
    && curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    # Cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ── Create non-root user ─────────────────────────────────────────────────────
RUN useradd -m -s /bin/bash vuser \
    && echo "vuser:vuser" | chpasswd \
    && usermod -aG sudo vuser \
    && echo "vuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ── Persistent data directory ────────────────────────────────────────────────
RUN mkdir -p /data && chown vuser:vuser /data

# ── noVNC symlink (so index.html is served correctly) ───────────────────────
RUN ln -sf /usr/share/novnc/vnc.html /usr/share/novnc/index.html

# ── Copy configuration files ─────────────────────────────────────────────────
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh

# ── Expose Railway's required port ──────────────────────────────────────────
EXPOSE 8080

# ── Entrypoint ───────────────────────────────────────────────────────────────
CMD ["/start.sh"]
