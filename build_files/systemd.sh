#!/usr/bin/bash
set -euo pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

log "Enabling system services"
#systemctl --global enable podman-auto-update.timer
systemctl enable docker.socket
systemctl enable qemu-guest-agent
systemctl enable podman.socket
#systemctl enable systemd-userdbd.service
#systemctl enable systemd-homed.service 
systemctl enable sshd.service
#systemctl enable homed-firstboot-users.service
systemctl enable homer-groups.service
systemctl enable pinggy.service
systemctl enable setup-caspertdk.service