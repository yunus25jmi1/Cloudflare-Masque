#!/bin/bash

set -e  # Exit on error

echo "Starting dbus manually..."
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# Check if Cloudflare WARP is installed
if ! command -v warp-cli &> /dev/null; then
    echo "Error: warp-cli not found! Make sure Cloudflare WARP is installed."
    exit 1
fi

# Start Cloudflare WARP daemon first
echo "Starting warp-svc..."
warp-svc &
sleep 10  # Allow time for the daemon to initialize

# Ensure Cloudflare WARP is registered
if [ ! -f /var/lib/cloudflare-warp/settings.json ]; then
    if [ -z "$WARP_AUTH_TOKEN" ]; then
        echo "Error: Cloudflare WARP registration token not provided!"
        exit 1
    fi
    echo "Registering Cloudflare WARP..."
    warp-cli --accept-tos register
    warp-cli --accept-tos set-license "$WARP_AUTH_TOKEN"
fi

# Connect to Cloudflare WARP
echo "Connecting to Cloudflare WARP..."
warp-cli --accept-tos connect

# Keep the container running
exec tail -f /dev/null
