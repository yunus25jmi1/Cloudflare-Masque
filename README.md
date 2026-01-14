# Cloudflare-Masque (Universal Zero Trust Bridge)

A lightweight, **universal** proxy that routes traffic through Cloudflare WARP / Zero Trust.

## Features
- **Platform Agnostic:** Runs on Render, Railway, Fly.io, Heroku, and Bare Metal.
- **Userspace Networking:** Uses `wireproxy` to avoid kernel dependency (`NET_ADMIN` not required).
- **Dual Mode:** 
    - **Anonymous:** Auto-registers a free WARP account (Best effort).
    - **Zero Trust:** Connects to your corporate Cloudflare Teams network using provided credentials.
- **Advanced Protocols:**
    - **SOCKS5:** Standard proxy on port `1080`.
    - **WebSocket Tunnel:** Wraps SOCKS5 in WebSocket on port `8080` (Bypasses strict firewalls).
- **Production Ready:** Includes Docker Healthchecks.

## 🚀 Quick Start (Docker)

```bash
docker run -d -p 1080:1080 --name masque cloudflare-masque
```

## ☁️ Zero Trust Configuration (Env Variables)

To connect to your Cloudflare Zero Trust organization, set these variables:

| Variable | Description | Example |
| :--- | :--- | :--- |
| `WG_PRIVATE_KEY` | Device Private Key | `kEDK...` |
| `WG_PEER_PUBLIC_KEY` | Cloudflare Peer Public Key | `bmXO...` |
| `WG_IPV6` | Assigned IPv6 Address | `2606:4700:...` |
| `WG_IPV4` | Assigned IPv4 Address | `172.16.0.2/32` |
| `WG_ENDPOINT` | (Optional) Custom Endpoint | `162.159.193.5:500` |
| `ENABLE_WS` | Enable WebSocket Tunnel | `true` |

### How to get credentials?
Use the [warp-login](https://github.com/rany2/warp-login) script or `warp-cli` to authenticate with your organization and extract the WireGuard keys.

## 📦 Deployment Guides

### Fly.io
1. Install `flyctl` and login.
2. Initialize app: `fly launch --no-deploy`
3. Set secrets:
   ```bash
   fly secrets set WG_PRIVATE_KEY=... WG_PEER_PUBLIC_KEY=... WG_IPV6=... WG_IPV4=...
   ```
4. Deploy: `fly deploy`

### Render
1. Create a **Web Service** (Docker).
2. Connect this repository.
3. Add Environment Variables in the dashboard.
4. Deploy!

## 🔌 WebSocket Tunneling
If TCP is blocked, enable WebSocket mode (`ENABLE_WS=true`).
- **Server:** Listens on port `8080`.
- **Client:** Use a tool like `gost` or `wstunnel` to connect:
  ```bash
  gost -L :1080 -F "ws://your-app-url:8080?path=/ws"
  ```
