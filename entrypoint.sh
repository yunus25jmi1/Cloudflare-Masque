#!/bin/sh
set -e

CONFIG_FILE="/app/wireproxy.conf"
WGCF_PROFILE="/app/wgcf-profile.conf"

echo ">>> Cloudflare Masque: Universal Zero-Trust Connector <<<"

# --- Step 1: Credentials Logic ---
# Check if Zero Trust / Custom keys are provided via ENV
if [ -n "$WG_PRIVATE_KEY" ] && [ -n "$WG_PEER_PUBLIC_KEY" ]; then
    echo "[Mode] ZERO TRUST / CUSTOM"
    echo "Using provided WireGuard credentials."
    
    PRIVATE_KEY="$WG_PRIVATE_KEY"
    PEER_PUBLIC_KEY="$WG_PEER_PUBLIC_KEY"
    
    # Default Endpoint for Cloudflare WARP/Zero Trust
    ENDPOINT=${WG_ENDPOINT:-"engage.cloudflareclient.com:2408"}
    
    # IP Addresses (Default placeholders if not provided, though ZT usually requires specific IPs)
    IPV4=${WG_IPV4:-"172.16.0.2/32"}
    IPV6=${WG_IPV6:-"2606:4700:110:8f86:5c03:41f2:92d3:6f45/128"}

else
    echo "[Mode] ANONYMOUS / CONSUMER"
    echo "No keys found. Attempting to generate free WARP credentials..."
    
    if [ ! -f "$WGCF_PROFILE" ]; then
        # Try to register. If it fails (e.g. cloud IP blocked), warn user.
        if echo "yes" | wgcf register; then
            wgcf generate
        else
            echo "Error: Registration failed. Cloudflare API might be blocking this IP."
            echo "Solution: Run this locally, generate 'wgcf-profile.conf', and mount it or set ENV vars."
            exit 1
        fi
    fi
    
    # Extract keys from the generated wgcf profile
    PRIVATE_KEY=$(grep 'PrivateKey' $WGCF_PROFILE | cut -d ' ' -f 3)
    PEER_PUBLIC_KEY=$(grep 'PublicKey' $WGCF_PROFILE | cut -d ' ' -f 3)
    IPV6=$(grep 'Address' $WGCF_PROFILE | grep ':' | cut -d ' ' -f 3)
    IPV4=$(grep 'Address' $WGCF_PROFILE | grep '\.' | cut -d ' ' -f 3)
    ENDPOINT=${WG_ENDPOINT:-"engage.cloudflareclient.com:2408"}
fi

# --- Step 2: Generate Wireproxy Config ---
echo "Generating wireproxy configuration..."

cat > $CONFIG_FILE <<EOF
[Interface]
PrivateKey = $PRIVATE_KEY
Address = $IPV4
Address = $IPV6
DNS = 1.1.1.1

[Peer]
PublicKey = $PEER_PUBLIC_KEY
Endpoint = $ENDPOINT
AllowedIPs = 0.0.0.0/0, ::/0
KeepAlive = 25

[Socks5]
BindAddress = 0.0.0.0:1080
EOF

# --- Step 3: Start the Proxy ---
if [ "$ENABLE_WS" = "true" ]; then
    echo "Starting SOCKS5 Proxy (wireproxy) + WebSocket Tunnel (gost)..."
    # Start wireproxy in background
    wireproxy -c $CONFIG_FILE &
    
    # Wait for wireproxy to be ready
    sleep 2
    
    # Start gost to forward WS :8080 -> SOCKS5 :1080
    echo "Starting WebSocket server on port 8080..."
    exec gost -L "ws://:8080?path=/ws&socks5=127.0.0.1:1080"
else
    echo "Starting SOCKS5 Proxy on port 1080..."
    exec wireproxy -c $CONFIG_FILE
fi
