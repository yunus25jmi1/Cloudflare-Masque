#!/bin/bash

set -e  # Exit on error

# Start D-Bus manually
echo "Starting dbus manually..."
mkdir -p /var/run/dbus
dbus-daemon --system --fork

# Check if Cloudflare WARP is installed
if ! command -v warp-cli &> /dev/null; then
    echo "Error: warp-cli not found! Make sure Cloudflare WARP is installed."
    exit 1
fi

# Ensure Cloudflare WARP is registered
if [ ! -f /var/lib/cloudflare-warp/settings.json ]; then
    if [ -z "$WARP_AUTH_TOKEN" ]; then
        echo "Error: Cloudflare WARP registration token not provided!"
        exit 1
    fi
    echo "Registering Cloudflare WARP..."
    warp-cli connector new "$WARP_AUTH_TOKEN"
    
    # Create empty settings file if registration fails
    [ ! -f /var/lib/cloudflare-warp/settings.json ] && echo "{}" > /var/lib/cloudflare-warp/settings.json
fi

# Connect to Cloudflare WARP
echo "Connecting to Cloudflare WARP..."
warp-cli connect

# Start the warp service
echo "Starting warp-svc..."
warp-svc &

# Keep the container running
exec tail -f /dev/null
