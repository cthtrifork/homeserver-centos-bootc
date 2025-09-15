#!/usr/bin/env bash
set -euo pipefail

ALL_SERVICES=$(systemctl list-unit-files --type=service --state=enabled --no-legend | awk "{print $1}" | grep -v "@\.service$")
echo "--- core services ---"
for s in $ALL_SERVICES; do
    systemctl is-active --quiet $s || {
    echo "Service not active: $s"
    systemctl status "$s" --no-pager || true
    exit 1
    }
done