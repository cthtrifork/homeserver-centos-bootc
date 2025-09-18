#!/usr/bin/env bash

USER=$1

# Setup OH-MY-BASH for user
HOME=/home/$USER
cd $HOME
export OSH="$HOME/.dotfiles/oh-my-bash"; bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended

# modify .bashrc
# https://github.com/ohmybash/oh-my-bash?tab=readme-ov-file
bash -c "sed -i 's/^plugins=(git)$/plugins=(git kubectl)/g' $HOME/.bashrc"
bash -c "echo 'export OMB_USE_SUDO=false' >> $HOME/.bashrc"
bash -c "echo 'export DISABLE_AUTO_UPDATE=true' >> $HOME/.bashrc"