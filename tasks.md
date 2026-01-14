# Development Tasks: Cloudflare-Masque

## Phase 1: Foundational Setup [COMPLETED]
- [x] Initial codebase audit.
- [x] Identification of architectural flaws (Kernel dependency vs. PaaS restrictions).
- [x] Design of Userspace Architecture.
- [x] Selection of core tools (`wireproxy`, `wgcf`).

## Phase 2: Core Implementation [COMPLETED]
- [x] Refactor `Dockerfile` to use Alpine and fetch static binaries.
- [x] Create `entrypoint.sh` with logic for Zero Trust vs. Anonymous mode.
- [x] Implement dynamic `wireproxy.conf` generation.
- [x] Update `README.md` with deployment instructions.

## Phase 3: Verification & Documentation [PENDING]
- [ ] **Task 3.1: Local Validation**
    - [x] Build and run locally to ensure SOCKS5 port 1080 is reachable.
    - [x] Test Anonymous registration flow (Verified logic; API blocked on this IP).
    - [x] Test Zero Trust manual key injection flow (Verified with yunusreview org).
- [ ] **Task 3.2: Cloud Deployment Testing**
    - [x] Create/Validate `fly.toml` for Fly.io.
    - [x] Validate/Update `render.yaml` for Render.
    - [ ] Validate on Render (Free Tier).
    - [ ] Validate on Fly.io (TCP handling).
- [ ] **Task 3.3: Advanced Features**
    - [x] Add WebSocket tunneling (using `gost`) for platforms that block TCP (Verified port 8080).
    - [x] Implement health-check script for Docker monitoring (Verified container health status).

## Phase 4: Finalization
- [ ] Cleanup legacy files (`danted.conf`, old `entrypoint.sh`).
- [ ] Prepare final repository structure for open-source release.
