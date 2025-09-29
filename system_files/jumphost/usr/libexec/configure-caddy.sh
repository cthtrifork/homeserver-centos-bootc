#!/usr/bin/env bash
set -euo pipefail

mkdir -p /etc/caddy-demo /var/lib/caddy-demo /etc/caddy
# Own the data dir as the caddy image's UID/GID 65532
chown -R 65532:65532 /var/lib/caddy-demo
# Config can stay root-owned but readable:
chmod 755 /etc/caddy-demo

echo "Caddy is now configured and is ready to run"