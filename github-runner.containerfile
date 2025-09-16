# syntax=docker/dockerfile:1.18@sha256:dabfc0969b935b2080555ace70ee69a5261af8a8f1b4df97b9e7fbcf6722eddf
FROM scratch AS ctx
COPY / /

FROM quay.io/centos-bootc/centos-bootc:stream9

#setup sudo to not require password
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo

# Write some metadata
RUN echo VARIANT="Github Runner bootc OS" && echo VARIANT_ID=com.github.caspertdk.homeserver-bootc >> /usr/lib/os-release

# Registry auth
ARG REGISTRY_TOKEN
ARG REGISTRY_URL
ARG REGISTRY_USERNAME

RUN --mount=type=secret,id=creds,required=true cp /run/secrets/creds /usr/lib/container-auth.json && \
    chmod 0600 /usr/lib/container-auth.json && \
    ln -sr /usr/lib/container-auth.json /etc/ostree/auth.json

# Configure repositories
RUN dnf -y install 'dnf-command(config-manager)'
RUN dnf -y install dnf-plugins-core procps-ng curl file qemu-guest-agent git rsync unzip jq lttng-ust openssl-libs krb5-libs zlib libicu tree

# Install docker
RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/server-docker-ce.sh

# Create runner user
RUN useradd --groups wheel,docker runner && \
    mkdir -m 0700 -p /home/runner/ && \
    chown -R runner: /home/runner && \
    mkdir -m 0700 -p /usr/share/runner && \
    chown -R runner: /usr/share/runner

ENV RUNNER_VERSION=2.328.0
RUN mkdir -p /usr/lib/actions-runner && \
    curl -fsSL -o /tmp/runner.tgz \
      https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar -xzf /tmp/runner.tgz -C /usr/lib/actions-runner && rm -f /tmp/runner.tgz && \
    chmod -R a+rX /usr/lib/actions-runner

ENV RUNNER_ALLOW_RUNASROOT="1"
ARG REPOSITORY
RUN --mount=type=secret,id=registry_token,required=true GITHUB_TOKEN="$(cat /run/secrets/registry_token)"; \
    mkdir -p /etc/homeserver/metadata && \
    echo "REPOSITORY=$REPOSITORY\nGITHUB_TOKEN=$GITHUB_TOKEN" > /etc/homeserver/metadata/github-runner && \
    chmod 600 /etc/homeserver/metadata/github-runner

# Install service
RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    rsync -rvpK /ctx/system_files/githubrunner/ /

# Cleanup
RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/cleanup.sh 

# Activate services
RUN systemctl enable docker.socket && \
    systemctl enable qemu-guest-agent && \
    systemctl enable podman.socket && \
    systemctl enable actions.runner.service

RUN bootc container lint
