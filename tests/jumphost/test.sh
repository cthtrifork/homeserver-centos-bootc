#!/usr/bin/env bash
set -euo pipefail

CORE_SERVICES="hosted-terminal.service" # todo
echo "--- core services ---"
for s in $CORE_SERVICES; do
    systemctl is-active --quiet "$s" || {
    echo "Service not active: $s"
    systemctl status "$s" --no-pager || true
    exit 1
    }
done
echo "all ok"

echo "Verifying reverse proxy..."
curl -iv -u admin:yourpassword http://localhost:8080/
