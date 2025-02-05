export DBUS_FATAL_WARNINGS=0
export NO_AT_BRIDGE=1
#!/bin/bash
export DBUS_FATAL_WARNINGS=0
export NO_AT_BRIDGE=1
set -eo pipefail



# Start the Cloudflare WARP service in the background
warp-svc --config=/var/lib/cloudflare-warp &

# Wait for the WARP daemon to be ready
echo "Waiting for WARP daemon..."
while ! warp-cli --accept-tos status >/dev/null 2>&1; do
    sleep 1
done

# Restore registration from environment variable if missing
if [ ! -s /var/lib/cloudflare-warp/reg.json ]; then
    echo "Restoring WARP registration..."
    if [ -n "$WARP_REGISTRATION_JSON" ]; then
        echo "$WARP_REGISTRATION_JSON" | base64 -d > /var/lib/cloudflare-warp/reg.json
    else
        echo "Creating new WARP registration..."
        warp-cli --accept-tos registration new
        cat /var/lib/cloudflare-warp/reg.json | base64 > /var/lib/cloudflare-warp/reg.b64
        echo "Save this value as WARP_REGISTRATION_JSON: $(cat /var/lib/cloudflare-warp/reg.b64)"
    fi
fi

warp-cli --accept-tos mode proxy

# Connect WARP
warp-cli --accept-tos connect
warp-cli --accept-tos status

# Start Dante proxy
echo "Starting Dante SOCKS5 proxy..."
exec /usr/sbin/danted -f /etc/danted.conf -D
