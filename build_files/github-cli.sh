#!/usr/bin/env bash

set -eou pipefail

# Setup repo
dnf config-manager addrepo --from-repofile=https://cli.github.com/packages/rpm/gh-cli.repo
dnf install -y gh --repo gh-cli
