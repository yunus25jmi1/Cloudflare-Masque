#!/bin/bash

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
    echo "Cloudflare WARP not registered. Registering..."
    warp-cli connector new eyJhIjoiMGZhOGNjZTg5Yjk0NTBkOTM1NzE0NWY2ZmU0NDkyY2QiLCJ0IjoiYTQ4OTZjMTQtMjUzYS00YjA5LWFmZDAtNjFmNGE1Y2Y5MzJhIiwicyI6IkVrdG5nV0pDNTBObitLS01sS0xnU0EzV09ENVprZXhNWlhYUHIyYVQ2NUdpWFV6RjlJa1Z3Z2IzYi8vcEJ5eXRGN3FiQU0xcGZFM3hJMUVOZGpRVDFnPT0ifQ==
    [ ! -f /var/lib/cloudflare-warp/settings.json ] && echo "{}" > /var/lib/cloudflare-warp/settings.json
fi

# Connect to WARP
echo "Connecting to Cloudflare WARP..."
warp-cli connect

# Run warp-svc in background
echo "Starting warp-svc..."
warp-svc &

# Keep the container running
tail -f /dev/null
