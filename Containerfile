# syntax=docker/dockerfile:1.18@sha256:dabfc0969b935b2080555ace70ee69a5261af8a8f1b4df97b9e7fbcf6722eddf
FROM scratch AS ctx
COPY / /

FROM quay.io/centos-bootc/centos-bootc:stream10@sha256:42fc456c6eeee3aa999c320febeaf33f62c9f0e50a37acdece90c3b264ac4bc1

#setup sudo to not require password
RUN echo "%wheel        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/wheel-sudo

# Write some metadata
RUN echo VARIANT="HomeServer bootc OS" && echo VARIANT_ID=com.github.caspertdk.homeserver-bootc >> /usr/lib/os-release

# Registry auth
ARG REGISTRY_TOKEN="notset"
ARG REGISTRY_URL="notset"
ARG REGISTRY_USERNAME="someuser"

RUN --mount=type=secret,id=creds,required=true cp /run/secrets/creds /usr/lib/container-auth.json && \
    chmod 0600 /usr/lib/container-auth.json && \
    ln -sr /usr/lib/container-auth.json /etc/ostree/auth.json

# Install common utilities
#RUN dnf -y group install 'Development Tools' # this one is huge and includes java!
RUN dnf -y install dnf-plugins-core procps-ng curl file qemu-guest-agent git firewalld rsync unzip
# python3-pip

# Configure repositories
RUN dnf -y install 'dnf-command(config-manager)'

# pip3 dependencies
# RUN pip3 install glances

RUN --mount=type=bind,from=ctx,src=/,dst=/ctx \
    #--mount=type=cache,dst=/var/cache \
    #--mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=secret,id=pinggy_token,required=true PINGGY_TOKEN="$(cat /run/secrets/pinggy_token)" \
    /ctx/build_files/build.sh

# Networking
#EXPOSE 8006
#RUN firewall-offline-cmd --add-port 8006/tcp

RUN bootc container lint
