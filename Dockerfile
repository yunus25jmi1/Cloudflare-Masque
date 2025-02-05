# Dockerfile
FROM ubuntu:20.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies including dbus and Cloudflare WARP
RUN apt-get update && \
    apt-get install -y \
    curl \
    dbus \
    iptables \
    gnupg \
    && apt-get clean

# Install Cloudflare WARP
RUN curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | \
    gpg --dearmor -o /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] \
    https://pkg.cloudflareclient.com/ jammy main" | \
    tee /etc/apt/sources.list.d/cloudflare-client.list

# Ensure necessary directories and permissions
RUN mkdir -p /var/lib/cloudflare-warp && \
    touch /var/lib/cloudflare-warp/settings.json /var/lib/cloudflare-warp/consumer-settings.json

# Entry point script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose necessary ports
EXPOSE 2408

# Start the WARP service using the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
