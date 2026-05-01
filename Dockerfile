FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# --- Core system update ---
RUN apt-get update && apt-get upgrade -y

# --- Install XFCE4 desktop + VNC + utilities ---
RUN apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    tigervnc-standalone-server \
    tigervnc-common \
    dbus-x11 \
    x11-xserver-utils \
    wget curl git \
    python3 python3-pip \
    neofetch \
    nano vim \
    net-tools \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Install noVNC v1.3.0 (stable) ---
RUN wget -qO /tmp/novnc.tar.gz \
      https://github.com/novnc/noVNC/archive/refs/tags/v1.3.0.tar.gz && \
    tar -xzf /tmp/novnc.tar.gz -C /opt && \
    mv /opt/noVNC-1.3.0 /opt/noVNC && \
    rm /tmp/novnc.tar.gz

# --- Install websockify (serves noVNC + proxies VNC) ---
RUN pip3 install websockify

# --- Redirect root URL to noVNC viewer ---
RUN ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# --- Copy startup script ---
COPY start.sh /start.sh
RUN chmod +x /start.sh

# --- Default env vars (override via Railway variables) ---
ENV VNC_PASSWORD=changeme
ENV PORT=8080

EXPOSE $PORT

CMD ["/start.sh"]
