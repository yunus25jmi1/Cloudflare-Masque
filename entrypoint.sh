#!/bin/bash
set -eo pipefail

# Start WARP service
warp-svc &

# Wait for WARP daemon
echo "Waiting for WARP daemon..."
while ! warp-cli --accept-tos status >/dev/null 2>&1; do
    sleep 1
done

# Create registration if missing
if [ ! -f /var/lib/cloudflare-warp/reg.json ]; then
    echo "Creating new WARP registration..."
    warp-cli --accept-tos registration new
fi

# Configure connector if token exists
if [ -n "$WARP_CONNECTOR_TOKEN" ]; then
    echo "Setting up WARP connector..."
    warp-cli --accept-tos connector new "$WARP_CONNECTOR_TOKEN"
fi

# Establish connection
echo "Connecting to WARP..."
warp-cli --accept-tos connect

# Verify connection
echo "Connection status:"
warp-cli --accept-tos status

# Wait for full connection
echo "Waiting for WARP connection..."
while ! warp-cli --accept-tos status | grep -q "Connected"; do
    sleep 1
done

# Start Dante
echo "Starting Dante SOCKS5 proxy..."
exec /usr/sbin/danted -f /etc/danted.conf -D