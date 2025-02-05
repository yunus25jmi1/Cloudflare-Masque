FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install base dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    apt-transport-https && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Provide a dummy systemctl to satisfy postinst scripts
RUN echo '#!/bin/sh\nexit 0' > /usr/bin/systemctl && chmod +x /usr/bin/systemctl

# Add Cloudflare repository
RUN curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | \
    gpg --dearmor -o /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] \
    https://pkg.cloudflareclient.com/ jammy main" | \
    tee /etc/apt/sources.list.d/cloudflare-client.list

# Install WARP and Dante
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    cloudflare-warp \
    dante-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Provide a dummy policy-rc.d to allow postinst scripts to exit successfully
RUN echo '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d && chmod +x /usr/sbin/policy-rc.d

# Configure system
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && \
    mkdir -p /var/lib/cloudflare-warp && \
    touch /var/lib/cloudflare-warp/reg.json && \
    chmod 600 /var/lib/cloudflare-warp/reg.json && \
    mkdir -p /var/run/danted

# Copy config files
COPY danted.conf /etc/danted.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK --interval=30s --timeout=10s \
    CMD curl --socks5 localhost:1080 -# -o /dev/null https://www.cloudflare.com || exit 1

ENTRYPOINT ["/entrypoint.sh"]
