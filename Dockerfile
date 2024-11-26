# Use an official lightweight Ubuntu image as the base
FROM ubuntu:20.04

# Set environment variables to prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y curl gnupg apt-transport-https sudo bat dante-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Step 1: Setup Cloudflare WARP Connector
RUN curl https://pkg.cloudflareclient.com/pubkey.gpg | sudo gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/cloudflare-client.list && \
    apt-get update && apt-get install -y cloudflare-warp

# Step 2: Enable IP forwarding
RUN echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && \
    sysctl -w net.ipv4.ip_forward=1

# Step 3: Copy and configure dante-server
COPY danted.conf /etc/danted.conf
RUN systemctl enable danted

# Step 4: Add Cloudflare WARP Connector token
ENV WARP_CONNECTOR_TOKEN="eyJhIjoiMGZhOGNjZTg5Yjk0NTBkOTM1NzE0NWY2ZmU0NDkyY2QiLCJ0IjoiYTQ4OTZjMTQtMjUzYS00YjA5LWFmZDAtNjFmNGE1Y2Y5MzJhIiwicyI6IkVrdG5nV0pDNTBObitLS01sS0xnU0EzV09ENVprZXhNWlhYUHIyYVQ2NUdpWFV6RjlJa1Z3Z2IzYi8vcEJ5eXRGN3FiQU0xcGZFM3hJMUVOZGpRVDFnPT0ifQ=="

# Run WARP Connector setup and Dante-server on container startup
CMD warp-cli connector new $WARP_CONNECTOR_TOKEN && \
    warp-cli connect && \
    systemctl restart danted && \
    tail -f /dev/null
