# syntax=docker/dockerfile:1.18@sha256:dabfc0969b935b2080555ace70ee69a5261af8a8f1b4df97b9e7fbcf6722eddf
FROM scratch AS ctx
COPY / /

FROM quay.io/centos-bootc/centos-bootc:stream10@sha256:42fc456c6eeee3aa999c320febeaf33f62c9f0e50a37acdece90c3b264ac4bc1

#setup sudo to not require password
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo

# Write some metadata
RUN echo VARIANT="Github Runner bootc OS" && echo VARIANT_ID=com.github.caspertdk.homeserver-bootc >> /usr/lib/os-release

# Registry auth
ARG REGISTRY_TOKEN="notset"
ARG REGISTRY_URL="notset"
ARG REGISTRY_USERNAME="someuser"

RUN --mount=type=secret,id=creds,required=true cp /run/secrets/creds /usr/lib/container-auth.json && \
    chmod 0600 /usr/lib/container-auth.json && \
    ln -sr /usr/lib/container-auth.json /etc/ostree/auth.json

# Configure repositories
RUN dnf -y install 'dnf-command(config-manager)'
RUN dnf -y install dnf-plugins-core procps-ng curl file qemu-guest-agent git rsync unzip jq lttng-ust openssl-libs krb5-libs zlib libicu

# Install docker
RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/server-docker-ce.sh

# Create runner user
RUN useradd --groups wheel,docker runner && \
    mkdir -m 0700 -p /home/runner/ && \
    chown -R runner: /home/runner

WORKDIR /home/runner

ENV RUNNER_VERSION=2.328.0
RUN curl -o actions-runner-linux.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
	&& tar xzf ./actions-runner-linux.tar.gz && \
	rm ./actions-runner-linux.tar.gz

ENV RUNNER_ALLOW_RUNASROOT="1"
ARG REPOSITORY="notset"
RUN --mount=type=secret,id=githubrunner_token,required=true GITHUB_RUNNER_TOKEN="$(cat /run/secrets/githubrunner_token)"; \
    ./config.sh --url $REPOSITORY --token ${GITHUB_RUNNER_TOKEN}

# Install service
RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    cp system_files/githubrunner/usr/lib/systemd/system/actions.runner.service usr/lib/systemd/system/actions.runner.service

RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build_files/cleanup.sh 

RUN bootc container lint
