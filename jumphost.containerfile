# syntax=docker/dockerfile:1.18@sha256:dabfc0969b935b2080555ace70ee69a5261af8a8f1b4df97b9e7fbcf6722eddf
FROM scratch AS ctx
COPY / /

FROM quay.io/centos-bootc/centos-bootc:stream9@sha256:3a75c664fbf8c540b0c75e9c0cac76828ee600bc58b4378c73a3d9a5eb2f0852

# Write some metadata
RUN echo VARIANT="Github Runner bootc OS" && echo VARIANT_ID=com.github.caspertdk.homeserver-bootc >> /usr/lib/os-release

# Registry auth
ARG REGISTRY_URL
ARG REGISTRY_USERNAME

RUN --mount=type=secret,id=creds,required=true cp /run/secrets/creds /usr/lib/container-auth.json && \
    chmod 0600 /usr/lib/container-auth.json && \
    ln -sr /usr/lib/container-auth.json /etc/ostree/auth.json

# Configure repositories
RUN dnf -y install 'dnf-command(config-manager)'
RUN dnf -y install dnf-plugins-core procps-ng file qemu-guest-agent \
    # Dev tools
    rsync

# Install service
RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    rsync -rvpK /ctx/system_files/jumphost/ /

# Cleanup
RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/cleanup.sh 

# Activate services
RUN mkdir -p /etc/containers/systemd && \
    ln -sr /usr/share/containers/systemd/demo-backend.container /etc/containers/systemd/demo-backend.container && \
    ln -sr /usr/share/containers/systemd/hosted-terminal.container /etc/containers/systemd/hosted-terminal.container && \
    ln -sr /usr/share/containers/systemd/reverse-proxy.container /etc/containers/systemd/reverse-proxy.container && \
    systemctl enable qemu-guest-agent && \
    systemctl enable podman.socket && \
    systemctl enable demo-backend.service && \
    systemctl enable hosted-terminal.service && \
    systemctl enable reverse-proxy.service && \
    systemctl enable podman-auto-update.timer
    
RUN bootc container lint
