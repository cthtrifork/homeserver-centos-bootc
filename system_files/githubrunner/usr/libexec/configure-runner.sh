#!/usr/bin/env bash
set -euo pipefail

DIST_DIR="/usr/lib/actions-runner" # (immutable)
STATE_DIR="/var/lib/actions-runner" 

cd "${STATE_DIR}"

# Copy distribution into /var if missing
if [[ ! -x run.sh ]]; then
  rsync -a --delete "${DIST_DIR}/" .
  chown -R runner:runner .
fi

# Register if not already
if [[ ! -f .runner ]]; then
  REG_TOKEN=$(curl -fsSL -X POST \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    "https://api.github.com/repos/${REPOSITORY}/actions/runners/registration-token" \
    | jq -r .token)

  sudo -u runner -E ./config.sh --replace \
    --url "https://github.com/${REPOSITORY}" \
    --token "${REG_TOKEN}" \
    --work "_work" \
    --labels "${LABELS}" \
    --unattended
fi

if [[ ! -f ./run-helper.sh ]]; then
  cp $STATE_DIR/run-helper.sh.template $STATE_DIR/run-helper.sh
fi

chmod +x run.sh
chmod +x run-helper.sh

exit 0