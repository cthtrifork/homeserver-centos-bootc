#!/usr/bin/env bash
set -euo pipefail

cat > /tmp/policy-permissive.json <<'EOF'
{ "default": [{"type":"insecureAcceptAnything"}] }
EOF

echo "Pulling image: ${IMAGE_FULL}:latest without signature verification"
skopeo copy --policy /tmp/policy-permissive.json docker://${IMAGE_FULL}:latest dir:$(mktemp -d ${HOME}/tmp-image.XXXXXX)
#podman pull --policy ${IMAGE_FULL}:latest

#DIGEST=$(skopeo inspect --raw docker://${IMAGE_FULL}:latest | jq -r '.manifests?[0].digest // .digest')
DIGEST=$(skopeo inspect --format "{{.Digest}}" docker://${IMAGE_FULL}:latest)

echo "Manually verifying image signature for image: ${IMAGE_FULL}@${DIGEST}"
cosign verify --key /etc/pki/cosign/cosign.pub ${IMAGE_FULL}@${DIGEST}

podman info --format '{{.Host.SignaturePolicyPath}}'

echo "Image signature verified manually. Pulling image: ${IMAGE_FULL}:latest"
podman pull ${IMAGE_FULL}@${DIGEST}
podman pull ${IMAGE_FULL}:latest
