#!/usr/bin/env bash
set -euo pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}


# Remove old stuff
dnf remove -y docker-cli moby-engine

# Setup repo
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

dnf install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

# prefer to have docker-compose available for legacy muscle-memory
ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose

# Docker sysctl.d
mkdir -p /usr/lib/sysctl.d
echo "net.ipv4.ip_forward = 1" >/usr/lib/sysctl.d/docker-ce.conf

log "Installed docker-ce"