FROM lscr.io/linuxserver/webtop:ubuntu-xfce

USER root

ENV TITLE="Ubuntu Desktop on Railway" \
    CUSTOM_USER=ubuntu \
    PASSWORD=changeme \
    TZ=Asia/Kolkata

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    nano \
    vim \
    htop \
    unzip \
    zip \
    xz-utils \
    procps \
    ca-certificates \
    python3 \
    python3-pip \
    nodejs \
    npm && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 3000 3001
