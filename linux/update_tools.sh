#!/bin/sh
# Update packages, dev tools, etc.

dnf upgrade -y

su --login luc -c '
source .zshrc

asdf plugin update --all
rustup update stable
pip install -U pip poetry pynvim
npm upgrade -g npm
'
