#!/usr/bin/env bash
set -euxo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <username>" >&2
  exit 1
fi

USER="$1"
HOME_DIR="/home/$USER"

cd $HOME_DIR

# Setup OH-MY-BASH for user
if [[ ! -d "${HOME_DIR}/.dotfiles/oh-my-bash" ]]; then
    export OSH="$HOME_DIR/.dotfiles/oh-my-bash"; bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended

    # modify .bashrc
    # https://github.com/ohmybash/oh-my-bash?tab=readme-ov-file
    sed -i 's/^plugins=(git)$/plugins=(git kubectl)/g' $HOME_DIR/.bashrc
    echo 'export OMB_USE_SUDO=false' >> $HOME_DIR/.bashrc
    echo 'export DISABLE_AUTO_UPDATE=true' >> $HOME_DIR/.bashrc
fi

echo "Finished setting up home for $USER"