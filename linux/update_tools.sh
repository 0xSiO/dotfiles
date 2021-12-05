#!/bin/sh
# Update packages, dev tools, vim plugins, etc.

dnf upgrade -y

su --login luc -c '
source .zshrc

asdf plugin update --all
rustup update stable
npm upgrade -g npm
nvim --headless +CocUpdateSync +qa
nvim --headless -c "autocmd User PackerComplete quitall" -c PackerSync
'
