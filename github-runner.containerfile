# syntax=docker/dockerfile:1.18@sha256:dabfc0969b935b2080555ace70ee69a5261af8a8f1b4df97b9e7fbcf6722eddf
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

RUN dnf -y install dnf-plugins-core procps-ng curl file qemu-guest-agent git rsync unzip

WORKDIR /usr/actions-runner
ENV VERSION=2.328.0
RUN curl -o actions-runner-linux.tar.gz -L https://github.com/actions/runner/releases/download/${VERSION}/actions-runner-linux-x64-${VERSION}.tar.gz \
	&& tar xzf ./actions-runner-linux.tar.gz && \
	rm ./actions-runner-linux.tar.gz

ENV RUNNER_ALLOW_RUNASROOT="1"
RUN --mount=type=secret,id=githubrunner_token,required=true GITHUB_RUNNER_TOKEN="$(cat /run/secrets/githubrunner_token)"; \
    ./config.sh --url https://github.com/cthtrifork/homeserver-centos-bootc --token ${GITHUB_RUNNER_TOKEN}

# todo move to own service? https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/configure-the-application
RUN ./svc.sh install

RUN bootc container lint
