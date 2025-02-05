#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

echo "Starting dbus manually..."
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# Start Cloudflare WARP daemon first
echo "Starting warp-svc..."
warp-svc &
sleep 2  # Allow time for warp-svc to initialize

# Check if Cloudflare WARP is registered
if [ ! -f /var/lib/cloudflare-warp/settings.json ]; then
    if [ -z "$WARP_AUTH_TOKEN" ]; then
        echo "Error: Cloudflare WARP registration token (WARP_AUTH_TOKEN) not provided!"
        exit 1
    fi
    echo "Registering Cloudflare WARP..."
    warp-cli --accept-tos register
    warp-cli --accept-tos set-license "$WARP_AUTH_TOKEN"
fi

# Ensure Cloudflare WARP is enabled
echo "Enabling Cloudflare WARP..."
warp-cli --accept-tos connect

# Keep the container running
exec tail -f /dev/null
