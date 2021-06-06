#!/bin/sh
# Update packages, dev tools, vim plugins, etc.

brew upgrade --greedy
asdf plugin update --all
rustup update stable
nvim --headless +PlugUpgrade +PlugUpdate +qa!
