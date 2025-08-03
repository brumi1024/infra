# Caddy Build

This directory contains the centralized Dockerfile for building Caddy with required modules across all sites.

## Modules Included

- **caddy-dynamicdns**: For automatic DNS updates (A/AAAA records)
- **caddy-dns/cloudflare**: For Cloudflare DNS challenge support

## Build Configuration

The Dockerfile builds Caddy v2.10.0 with the following process:
1. Uses `xcaddy` to compile Caddy with additional modules
2. Creates a minimal final image with just the compiled binary

## Usage

This build is referenced by all site-specific Caddy deployments:
- VPS: `/services/admin/vps/caddy/compose.yml`
- Main/Home: `/services/admin/home/caddy/compose.yml`
- Sequoia: `/services/admin/sequoia/caddy/compose.yml`

Each compose file references this build directory:
```yaml
build:
  context: ${REPODIR}/services/admin/caddy-build
  dockerfile: Dockerfile
```

## Building Manually

To build the image manually:
```bash
cd /path/to/infra/services/admin/caddy-build
docker build -t caddy-custom:latest .
```

## Updating Caddy Version

To update the Caddy version, modify the `ARG CADDY_VERSION` line in the Dockerfile:
```dockerfile
ARG CADDY_VERSION=2.10.0  # Change this version
```

## Adding New Modules

To add additional Caddy modules:
1. Edit the Dockerfile
2. Add new `--with` lines to the `xcaddy build` command
3. Rebuild on all sites

Example:
```dockerfile
RUN xcaddy build \
    --with github.com/mholt/caddy-dynamicdns \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/new/module
```