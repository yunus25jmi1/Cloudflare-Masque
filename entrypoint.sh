#!/bin/bash
set -eo pipefail

export DBUS_FATAL_WARNINGS=0
export NO_AT_BRIDGE=1

# Start the Cloudflare WARP service in the background
warp-svc --config=/var/lib/cloudflare-warp &

echo "Waiting for WARP daemon to be ready..."
while ! warp-cli --accept-tos status >/dev/null 2>&1; do
    sleep 1
done

# Handle registration
if [ ! -s /var/lib/cloudflare-warp/reg.json ]; then
    echo "No existing registration found."

    if [ -n "$WARP_REGISTRATION_JSON" ]; then
        echo "Using provided WARP_REGISTRATION_JSON..."
        echo "$WARP_REGISTRATION_JSON" | base64 -d > /var/lib/cloudflare-warp/reg.json
    elif [ -n "$WARP_CONNECTOR_TOKEN" ]; then
        echo "Using WARP_CONNECTOR_TOKEN to enroll..."
        warp-cli --accept-tos teams-enroll "$WARP_CONNECTOR_TOKEN"
    else
        echo "Creating a new WARP registration..."
        warp-cli --accept-tos register
        if [ $? -ne 0 ]; then
            echo "Failed to create new registration."
            exit 1
        fi

        # Save registration for future use
        cat /var/lib/cloudflare-warp/reg.json | base64 > /var/lib/cloudflare-warp/reg.b64
        echo "Save this value as WARP_REGISTRATION_JSON: $(cat /var/lib/cloudflare-warp/reg.b64)"
    fi
fi

# Set WARP to proxy mode
warp-cli --accept-tos set-mode proxy

# Connect WARP
echo "Connecting to WARP..."
warp-cli --accept-tos connect
if [ $? -ne 0 ]; then
    echo "WARP connection failed."
    exit 1
fi

# Check connection status
echo "WARP Connection Status:"
warp-cli --accept-tos status

# Update danted.conf with the correct external interface
DEFAULT_IFACE=$(ip route | awk '/default/ {print $5}')
sed -i "s|external: eth0|external: $DEFAULT_IFACE|" /etc/danted.conf

# Start Dante SOCKS5 proxy
echo "Starting Dante SOCKS5 proxy..."
exec /usr/sbin/danted -f /etc/danted.conf -D
