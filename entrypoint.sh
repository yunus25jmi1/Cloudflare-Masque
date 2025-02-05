#!/bin/bash
set -eo pipefail

export DBUS_FATAL_WARNINGS=0
export NO_AT_BRIDGE=1

# Start the Cloudflare WARP service in the background
warp-svc --config=/var/lib/cloudflare-warp &

# Wait for the WARP daemon to be ready
echo "Waiting for WARP daemon..."
while ! warp-cli --accept-tos status >/dev/null 2>&1; do
    sleep 1
done

# Restore registration or use WARP_CONNECTOR_TOKEN
if [ ! -s /var/lib/cloudflare-warp/reg.json ]; then
    echo "Restoring WARP registration..."
    if [ -n "$WARP_REGISTRATION_JSON" ]; then
        echo "$WARP_REGISTRATION_JSON" | base64 -d > /var/lib/cloudflare-warp/reg.json
    elif [ -n "$WARP_CONNECTOR_TOKEN" ]; then
        echo "Using WARP Connector Token..."
        warp-cli --accept-tos teams-enroll "$WARP_CONNECTOR_TOKEN"
    else
        echo "Creating new WARP registration..."
        warp-cli --accept-tos registration new
        cat /var/lib/cloudflare-warp/reg.json | base64 > /var/lib/cloudflare-warp/reg.b64
        echo "Save this value as WARP_REGISTRATION_JSON: $(cat /var/lib/cloudflare-warp/reg.b64)"
    fi
fi

# Set WARP in proxy mode and connect
warp-cli --accept-tos mode proxy
warp-cli --accept-tos connect
warp-cli --accept-tos status

# Dynamically set the external network interface for Dante
DEFAULT_IFACE=$(ip route | awk '/default/ {print $5}')
sed -i "s|external: REPLACE_AT_RUNTIME|external: $DEFAULT_IFACE|" /etc/danted.conf

# Start Dante SOCKS5 proxy
echo "Starting Dante SOCKS5 proxy..."
exec /usr/sbin/danted -f /etc/danted.conf -D
