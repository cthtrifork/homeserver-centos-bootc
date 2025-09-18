#!/usr/bin/env bash
set -euo pipefail

cd /home/runner/actions-runner || cd /actions-runner || true

REG_TOKEN=$(curl -fsSL -X POST \
    -H "Authorization: token ${GITHUB_TOKEN}" \
    "https://api.github.com/repos/${REPOSITORY}/actions/runners/registration-token" \
    | jq -r .token)

if [[ -z "${REG_TOKEN}" || "${REG_TOKEN}" == "null" ]]; then
    echo "[entrypoint] ERROR: Failed to retrieve a valid registration token from GitHub API." >&2
    exit 1
fi
args=( --unattended --url "https://github.com/${REPOSITORY}" --token "${REG_TOKEN}" )
[[ -n "${RUNNER_NAME:-}" ]] && args+=( --name "${RUNNER_NAME}" )
[[ -n "${RUNNER_LABELS:-}" ]] && args+=( --labels "${RUNNER_LABELS}" )
[[ "${RUNNER_EPHEMERAL:-false}" == "true" ]] && args+=( --ephemeral )
[[ "${RUNNER_DISABLE_UPDATE:-false}" == "true" ]] && args+=( --disableupdate )

# Work dir lives at /_work (bind-mounted). Keep it consistent with --work and the Volume.
args+=( --work "/_work" )
# If restarted with same name, replace old registration:
args+=( --replace )

echo "[entrypoint] Configuring runner with: ${args[*]}"
./config.sh "${args[@]}"

./config.sh --check --url "https://github.com/${REPOSITORY}" --token "${REG_TOKEN}"

exec ./run.sh
