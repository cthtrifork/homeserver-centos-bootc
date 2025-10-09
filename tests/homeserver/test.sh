#!/usr/bin/env bash
set -euo pipefail

echo "Verifying status for custom installed services..."
CORE_SERVICES="pinggy.service homer-groups.service setup-caspertdk.service" # todo: detect
echo "--- core services ---"
for s in $CORE_SERVICES; do
    systemctl is-active --quiet "$s" || {
    echo "Service not active: $s"
    systemctl status "$s" --no-pager || true
    exit 1
    }
done
echo "all ok"



echo "== caspertdk: home directory exists =="
sudo test -d /home/caspertdk || echo "❌ home directory missing"; exit 1;
sudo test -f /home/caspertdk/.gitconfig || echo "❌ git config missing"; exit 1;
echo "✅ homed user creation + authorized keys OK"

# check if env var ENV_LOAD is loaded
if [ -z "${ENV_LOAD:-}" ]; then
    echo "ENV_LOAD is not set"
    exit 1
fi
echo "ENV_LOAD is set to '$ENV_LOAD'. /etc/profile.d is working as intended."

echo "Checking if user is in docker group"
docker run --rm hello-world

echo "Checking github Auth status"
gh auth status
