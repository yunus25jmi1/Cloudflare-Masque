# Requirements Specification: Cloudflare-Masque

## 1. Project Overview
A universal, containerized proxy bridge that routes traffic through Cloudflare's network (Consumer WARP or Enterprise Zero Trust). It must be platform-agnostic, running on restrictive cloud environments (PaaS) and bare-metal servers.

## 2. Functional Requirements
- **FR1: Dual Authentication Modes**
    - **Anonymous Mode:** Auto-register a free Cloudflare WARP account on startup.
    - **Zero Trust Mode:** Accept pre-provisioned WireGuard keys (Private Key, Peer Key, IPv4/v6) to join a Cloudflare One (Teams) organization.
- **FR2: Userspace Networking**
    - Must NOT require `NET_ADMIN` or `privileged` mode.
    - Must NOT modify the host system's network interfaces.
- **FR3: Proxy Support**
    - Expose a SOCKS5 proxy on port 1080.
    - (Optional/Future) Expose an HTTP proxy bridge.
- **FR4: DNS Security**
    - Force all DNS resolution through Cloudflare's secure resolvers (1.1.1.1 or Zero Trust Gateway).

## 3. Technical Constraints
- **Architecture:** Must use a userspace WireGuard implementation (e.g., `wireproxy`).
- **Base Image:** Minimal footprint (Alpine Linux preferred).
- **Environment:** Must be compatible with Render, Railway, Fly.io, and Heroku.

## 4. Performance & Security
- **Kill Switch:** Traffic must only exit through the tunnel. If the tunnel drops, the proxy service should become unreachable (inherent in `wireproxy` design).
- **Latency:** Protocol overhead should be minimal (WireGuard performance).
- **Privacy:** No local logging of user traffic or destination IPs.
