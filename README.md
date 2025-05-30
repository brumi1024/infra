# HomeLab Infrastructure

A comprehensive Docker Compose-based homelab infrastructure setup for self-hosted services including media management, monitoring, authentication, and personal applications.

## Architecture

This infrastructure uses:
- **Caddy** as a reverse proxy with automatic HTTPS and Cloudflare DNS integration
- **Authentik** for centralized authentication and SSO
- **Docker Socket Proxy** for secure Docker API access
- **Homepage** as a unified dashboard
- **Tailscale** for secure networking between services

## Services

### Core Infrastructure
- **[Caddy](services/admin/caddy/compose.yml)** - Reverse proxy with automatic HTTPS
- **[Authentik](services/admin/authentik/compose.yml)** - Identity provider and SSO
- **[Docker Socket Proxy](services/admin/proxy/compose.yml)** - Secure Docker API access
- **[Homepage](services/homepage/compose.yml)** - Unified dashboard

### Personal Applications
- **[Actual Budget](services/actualbudget/compose.yml)** - Personal finance management
- **[Paperless](services/paperless/compose.yml)** - Document management system
- **[Stirling PDF](services/stirlingpdf/compose.yml)** - PDF manipulation tools
- **[Immich](services/immich/compose.yml)** - Photo and video management

### Media Stack
- **[Servarr Stack](services/servarr/compose.yml)** - Complete media automation
  - Prowlarr (indexer management)
  - Sonarr (TV shows)
  - Radarr (movies)
  - Readarr (books)
  - Overseerr (request management)
  - qBittorrent (torrent client)
- **[Tautulli](services/tautulli/compose.yml)** - Plex analytics and monitoring

### Monitoring & Smart Home
- **[Beszel](services/monitoring/compose.yml)** - System monitoring
- **[Uptime Kuma](services/uptime-kuma/compose.yml)** - Uptime monitoring
- **[Frigate](services/frigate/compose.yml)** - NVR for security cameras

### Administration
- **[Nebula Sync](services/admin/nebula-sync/compose.yml)** - Pi-hole synchronization

## Installation

### Prerequisites

1. Docker and Docker Compose installed
2. Tailscale VPN configured
3. Cloudflare account for DNS management
4. NFS storage configured (if using NAS)

### Setup

1. **Install Loki Docker Log Driver** ([Docs](https://grafana.com/docs/loki/latest/send-data/docker-driver/)):
   ```bash
   docker plugin install grafana/loki-docker-driver:3.4.2-amd64 --alias loki --grant-all-permissions
   ```

2. **Configure the log driver** in `/etc/docker/daemon.json`:
   ```json
   {
       "log-driver": "loki",
       "log-opts": {
           "mode":"non-blocking",
           "loki-url": "http://localhost:3100/loki/api/v1/push",
           "loki-batch-size": "400",
           "loki-retries": "2",
           "loki-max-backoff":"800ms",
           "loki-timeout":"1s"
       }
   }
   ```

3. **Restart Docker service**:
   ```bash
   sudo systemctl restart docker
   ```

4. **Prepare Docker networks**:
   ```bash
   ./scripts/prepare.sh
   ```

5. **Configure environment**:
   ```bash
   cp env.template actual.env
   # Edit actual.env with your specific configuration
   ```

6. **Deploy services**:
   ```bash
   # Deploy core infrastructure first
   cd services
   docker compose -p core \
     -f admin/caddy/compose.yml \
     -f admin/authentik/compose.yml \
     -f admin/proxy/compose.yml \
     --env-file ../actual.env up -d

   # Deploy applications
   docker compose -p services \
     -f homepage/compose.yml \
     -f actualbudget/compose.yml \
     -f paperless/compose.yml \
     -f immich/compose.yml \
     --env-file ../actual.env up -d

   # Deploy media stack
   docker compose -p media \
     -f servarr/compose.yml \
     -f tautulli/compose.yml \
     --env-file ../actual.env up -d
   ```

## Configuration

### Environment Variables

Copy [`env.template`](env.template) to `actual.env` and configure:

- **Core settings**: PUID, PGID, TZ, domain names
- **Network**: Tailscale network, host names
- **Storage**: NAS IP addresses, mount paths
- **Ports**: Service port mappings
- **API keys**: Service authentication tokens
- **OAuth**: Authentik configuration for SSO

### Network Architecture

- `caddy-net`: Main application network
- `socky_proxy-net`: Isolated network for Docker socket proxy

### Storage

- **NFS volumes**: Media, application data, and configuration
- **Local volumes**: Database storage for critical services
- **Configuration**: Host-mounted for easy management

## Service Access

All services are accessible through the configured domain with automatic HTTPS:

- Dashboard: `https://dash.yourdomain.com`
- Authentication: `https://auth.yourdomain.com`
- Individual services: `https://[service].yourdomain.com`

## Monitoring

- **Homepage**: Centralized dashboard with service widgets
- **Beszel**: System resource monitoring
- **Uptime Kuma**: Service availability monitoring
- **Tautulli**: Media server analytics

## Security

- **Authentik SSO**: Centralized authentication for all services
- **Docker Socket Proxy**: Secure, read-only Docker API access
- **Tailscale VPN**: Private network overlay
- **Cloudflare**: DNS and proxy protection
- **Automatic HTTPS**: Via Caddy with Let's Encrypt

## Backup Considerations

Critical data locations to backup:
- `/srv/docker-config/` - Service configurations
- Database volumes for Authentik, Paperless, Immich
- Media library and document storage

## License

Licensed under the [Apache License 2.0](LICENSE).