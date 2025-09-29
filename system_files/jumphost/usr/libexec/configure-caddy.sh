#!/usr/bin/env bash
set -euo pipefail

# Create config + state dirs
mkdir -p /etc/caddy-demo /etc/caddy /var/lib/caddy-demo /var/lib/caddy-frontend

# Ensure non-root Caddy (uid/gid 65532) can write to the data dirs
chown -R 65532:65532 /var/lib/caddy-demo /var/lib/caddy-frontend

# If you keep configs locally, make them readable
chmod 755 /etc/caddy-demo /etc/caddy

echo "Caddy is now configured and is ready to run"