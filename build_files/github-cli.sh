#!/usr/bin/env bash

set -eou pipefail

# Setup repo
dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
dnf -y install gh --repo gh-cli
