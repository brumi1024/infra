# Docker IPv6 Configuration for Sequoia Caddy

## Prerequisites
Run these commands on the Sequoia host (the machine running Docker).

## 1. Enable IPv6 in Docker Daemon

Create or edit the Docker daemon configuration file:

```bash
sudo nano /etc/docker/daemon.json
```

Add the following configuration:

```json
{
  "ipv6": true,
  "fixed-cidr-v6": "fd00::/80",
  "ip6tables": true,
  "experimental": false
}
```

**Note**: The `fd00::/80` is a Unique Local Address (ULA) range. Docker will automatically allocate subnets from this range.

## 2. Restart Docker

After saving the configuration, restart the Docker daemon:

```bash
sudo systemctl restart docker
```

## 3. Verify IPv6 is Enabled

Check if IPv6 is working:

```bash
# Check Docker network configuration
docker network inspect caddy-net

# You should see IPv6 configuration in the output
```

## 4. Create the External Network (if not exists)

If the `caddy-net` network doesn't exist or needs IPv6 support:

```bash
docker network create \
  --driver bridge \
  --ipv6 \
  --subnet fd00:1::/64 \
  caddy-net
```

## 5. Alternative: Port Binding for IPv6

If you want to explicitly bind to IPv6 addresses, update the compose.yml ports section:

```yaml
ports:
  - "80:80"              # Binds to both IPv4 and IPv6
  - "443:443"            # Binds to both IPv4 and IPv6
  - "443:443/udp"        # Binds to both IPv4 and IPv6
  - "2019:2019"          # Admin port
```

Or for IPv6-only binding:
```yaml
ports:
  - ":::80:80"           # IPv6 only
  - ":::443:443"         # IPv6 only
```

## 6. Firewall Configuration

Ensure your firewall allows IPv6 traffic:

```bash
# For UFW
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 443/udp

# For ip6tables directly
sudo ip6tables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo ip6tables -A INPUT -p tcp --dport 443 -j ACCEPT
sudo ip6tables -A INPUT -p udp --dport 443 -j ACCEPT
```

## Troubleshooting

1. Check if the container has IPv6 address:
   ```bash
   docker exec caddy ip -6 addr show
   ```

2. Test IPv6 connectivity from inside container:
   ```bash
   docker exec caddy ping6 -c 4 2001:4860:4860::8888
   ```

3. Check if Caddy is listening on IPv6:
   ```bash
   docker exec caddy ss -tlnp | grep -E '(:80|:443)'
   ```