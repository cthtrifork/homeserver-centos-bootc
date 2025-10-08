#!/usr/bin/env bash
set -euo pipefail

echo "Verifying status for custom installed services..."
CORE_SERVICES="pinggy.service homer-groups.service" # todo: detect
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
sudo test -d /home/caspertdk || (exit 1 && echo "home directory missing")
sudo test -f /home/caspertdk/.gitconfig || (exit 1 && echo "git config missing")
sudo homectl inspect caspertdk || (exit 1 && echo "user missing")
userdbctl ssh-authorized-keys caspertdk || (exit 1 && echo "authorized keys missing")
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
