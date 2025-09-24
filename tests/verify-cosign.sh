#!/usr/bin/env bash
set -euo pipefail

scopeo_verify() {
    cat > /tmp/policy-permissive.json <<'EOF'
    { "default": [{"type":"insecureAcceptAnything"}] }
EOF

    echo "Pulling image: ${IMAGE_FULL}:latest without signature verification"
    skopeo copy --policy /tmp/policy-permissive.json docker://${IMAGE_FULL}:latest dir:$(mktemp -d ${HOME}/tmp-image.XXXXXX)
    DIGEST=$(skopeo inspect --format "{{.Digest}}" docker://${IMAGE_FULL}:latest)
    echo "Manually verifying image signature for image: ${IMAGE_FULL}@${DIGEST}"
    cosign verify --key /etc/pki/cosign/cosign.pub ${IMAGE_FULL}@${DIGEST}
    echo "Image signature verified manually"
}

podman_pull_without_trust() {
    cat > /tmp/policy-permissive.json <<'EOF'
    { "default": [{"type":"insecureAcceptAnything"}] }
EOF
    echo "Pulling image: ${IMAGE_FULL}:latest without signature verification"
    podman pull --signature-policy /tmp/policy-permissive.json ${IMAGE_FULL}@latest
}

#podman pull --log-level=debug ${IMAGE_FULL}:latest 2>&1 | grep -iE 'digest|signature|sigstore' || true
podman pull ${IMAGE_FULL}:latest
