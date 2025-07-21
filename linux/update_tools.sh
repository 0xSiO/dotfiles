#!/bin/sh
# Update packages, dev tools, etc.

dnf upgrade -y

su --login luc -c '
source .zshrc

rustup update stable
'
