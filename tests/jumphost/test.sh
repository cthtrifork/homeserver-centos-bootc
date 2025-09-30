#!/usr/bin/env bash
set -euo pipefail

echo "Verifying reverse proxy..."

sudo tree /var/lib/caddy-demo
curl -u admin:yourpassword http://localhost:8080/health | grep "ok"
