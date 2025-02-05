#!/bin/bash
set -eo pipefail

# Start the Cloudflare WARP service in the background
warp-svc &

# Wait for the Warp daemon to be ready
echo "Waiting for WARP daemon..."
while ! warp-cli --accept-tos status >/dev/null 2>&1; do
    sleep 1
done

# If registration file is missing, create a new registration
if [ ! -f /var/lib/cloudflare-warp/reg.json ]; then
    echo "Creating new WARP registration..."
    warp-cli --accept-tos registration new
fi

# If a WARP connector token is provided, set up the connector
if [ -n "$WARP_CONNECTOR_TOKEN" ]; then
    echo "Setting up WARP connector..."
    warp-cli --accept-tos connector new "$WARP_CONNECTOR_TOKEN"
fi

# Establish the WARP connection
echo "Connecting to WARP..."
warp-cli --accept-tos connect

# Display current connection status
echo "Connection status:"
warp-cli --accept-tos status

# Wait until the status shows "Connected"
echo "Waiting for WARP connection..."
while ! warp-cli --accept-tos status | grep -q "Connected"; do
    sleep 1
done

# Start Dante in the foreground (do not daemonize)
echo "Starting Dante SOCKS5 proxy..."
exec /usr/sbin/danted -f /etc/danted.conf -D
