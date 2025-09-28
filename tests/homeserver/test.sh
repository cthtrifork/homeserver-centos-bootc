#!/usr/bin/env bash
set -euo pipefail

CORE_SERVICES="pinggy.service homer-groups.service" # todo
echo "--- core services ---"
for s in $ALL_SERVICES; do
    systemctl is-active --quiet "$s" || {
    echo "Service not active: $s"
    systemctl status "$s" --no-pager || true
    exit 1
    }
done
echo "all ok"