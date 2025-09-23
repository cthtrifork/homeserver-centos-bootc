# syntax=docker/dockerfile:1.18@sha256:dabfc0969b935b2080555ace70ee69a5261af8a8f1b4df97b9e7fbcf6722eddf
FROM scratch AS ctx
COPY / /

FROM quay.io/centos-bootc/centos-bootc:stream9@sha256:3a75c664fbf8c540b0c75e9c0cac76828ee600bc58b4378c73a3d9a5eb2f0852

#setup sudo to not require password
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo

# Write some metadata
RUN echo VARIANT="HomeServer bootc OS" && echo VARIANT_ID=com.github.caspertdk.homeserver-bootc >> /usr/lib/os-release

# Registry auth
ARG REGISTRY_URL
ARG REGISTRY_USERNAME

RUN --mount=type=secret,id=creds,required=true \
    cp /run/secrets/creds /usr/lib/container-auth.json && \
    chmod 0600 /usr/lib/container-auth.json && \
    \
    # For rpm-ostree / bootc / ostree-container pulls
    ln -sf /usr/lib/container-auth.json /etc/ostree/auth.json && \
    \
    # For podman/skopeo/buildah (root context)
    mkdir -p /etc/containers && \
    ln -sf /usr/lib/container-auth.json /etc/containers/auth.json && \
    \
    # For docker CLI (real Docker or the podman-docker shim): per-daemon fallback
    mkdir -p /etc/docker && \
    ln -sf /usr/lib/container-auth.json /etc/docker/config.json && \
    printf "REGISTRY_AUTH_FILE=~/.config/containers/auth.json\n" | tee -a /etc/environment

# Install common utilities
#RUN dnf -y group install 'Development Tools' # this one is huge and includes java!
RUN dnf -y install \
      dnf-plugins-core \
      procps-ng \
      curl \
      file \
      qemu-guest-agent \
      firewalld \
      rsync \
      unzip \
      # python3-pip
      tree \
      git \
    && dnf -y install 'dnf-command(config-manager)'

# pip3 dependencies
# RUN pip3 install glances

ARG PINGGY_HOST
RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    #--mount=type=cache,dst=/var/cache \
    #--mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=pinggy_token,required=true PINGGY_TOKEN="$(cat /run/secrets/pinggy_token)" \
    PINGGY_HOST="${PINGGY_HOST}" \
    /ctx/build_files/build.sh


# COSIGN
ADD cosign.pub /etc/pki/cosign/cosign.pub
ADD policy.json /etc/containers/policy.json
RUN chmod 0644 /etc/pki/cosign/cosign.pub /etc/containers/policy.json

# Networking
#EXPOSE 8006
#RUN firewall-offline-cmd --add-port 8006/tcp

RUN bootc container lint
