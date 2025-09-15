#!/usr/bin/bash
# shellcheck disable=SC1091

set -euo pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

rsync -rvpK /ctx/system_files/homeserver/ /

mkdir -p /etc/homeserver/metadata/
touch /etc/homeserver/metadata/pinggy
echo "PINGGY_TOKEN=$PINGGY_TOKEN" >> /etc/homeserver/metadata/pinggy
echo "PINGGY_HOST=$PINGGY_HOST" >> /etc/homeserver/metadata/pinggy
chmod 600 /etc/homeserver/metadata/pinggy # todo: consider systemd credentials

/ctx/build_files/github-cli.sh
/ctx/build_files/server-docker-ce.sh
/ctx/build_files/utilities.sh
/ctx/build_files/systemd.sh
/ctx/build_files/cleanup.sh

log "Build process completed"