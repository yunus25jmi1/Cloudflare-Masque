#!/bin/bash
# entrypoint.sh

# Start D-Bus if not running
if ! systemctl is-active --quiet dbus; then
    echo "Starting dbus..."
    systemctl start dbus
fi

# Check if Cloudflare WARP is registered, if not, register it
if [ ! -f /var/lib/cloudflare-warp/settings.json ]; then
    echo "Cloudflare WARP not registered. Registering..."
    warp-cli register
    # Optionally, create empty settings if registration fails
    [ ! -f /var/lib/cloudflare-warp/settings.json ] && echo "{}" > /var/lib/cloudflare-warp/settings.json
fi

# Start the WARP daemon
warp-cli connect

# Start firewall service if needed (depending on your configuration)
# If using ufw or iptables, ensure necessary ports are open
# sudo ufw allow 2408/tcp
# sudo ufw allow 2408/udp

# Run the WARP service
warp-svc &

# Wait for the service to initialize and handle additional startup processes
wait
