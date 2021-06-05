#!/bin/sh
# Update packages, dev tools, vim plugins, etc.

# sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y

brew upgrade --greedy
asdf plugin update --all
rustup update stable
nvim --headless +PlugUpgrade +PlugUpdate +qa!
