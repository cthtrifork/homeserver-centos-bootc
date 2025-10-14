#!/usr/bin/bash

set -euo pipefail

trap '[[ $BASH_COMMAND != echo* ]] && [[ $BASH_COMMAND != log* ]] && echo "+ $BASH_COMMAND"' DEBUG

log() {
  echo "=== $* ==="
}

SOPS_AGE_KEY_FILE="/etc/sops/age/keys.txt"

if [[ ! -f "$SOPS_AGE_KEY_FILE" ]]; then
  echo "Error: SOPS_AGE_KEY_FILE ($SOPS_AGE_KEY_FILE) does not exist" >&2
  exit 1
fi

log "Decrypting SSH key"
/usr/bin/install -d -m 0700 /var/lib/secrets/ssh
sops --decrypt --output /var/lib/secrets/ssh/id_ed25519 /usr/share/secrets/ssh/id_ed25519.sops
chmod 600 /var/lib/secrets/ssh/id_ed25519