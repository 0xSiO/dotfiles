#!/bin/sh
# Update packages, dev tools, vim plugins, etc.

dnf upgrade -y
sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- -y

sudo -i -u luc << END

asdf plugin update --all
rustup update stable
npm upgrade -g
nvim --headless +PlugUpgrade +PlugUpdate +qa!

END
