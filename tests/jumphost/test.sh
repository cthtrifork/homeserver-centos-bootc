#!/usr/bin/env bash
set -euo pipefail

echo "Verifying reverse proxy..."

tree /var/lib/caddy-demo
curl -iv -u admin:yourpassword http://localhost:8080/
