#!/usr/bin/env bash
set -euo pipefail

# demo-backend.container
mkdir -p /etc/caddy-demo /var/lib/caddy-demo
# Own the data dir as the caddy image's UID/GID 65532
chown -R 65532:65532 /var/lib/caddy-demo
# Config can stay root-owned but readable:
chmod 755 /etc/caddy-demo

# reverse-proxy.container
mkdir -p /etc/caddy /var/lib/caddy-frontend 
# Ensure Caddy can write its data
chown -R 65532:65532 /var/lib/caddy-frontend
chmod 755 /etc/caddy

echo "Caddy is now configured and is ready to run"