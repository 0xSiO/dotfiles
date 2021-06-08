#!/bin/sh
# Update packages, dev tools, vim plugins, etc.

dnf upgrade -y

sudo -i -u luc << END

asdf plugin update --all
rustup update stable
npm upgrade -g npm neovim
nvim --headless +PlugUpgrade +PlugUpdate +qa!

END
