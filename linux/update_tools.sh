#!/bin/sh
# Update packages, dev tools, vim plugins, etc.

dnf upgrade -y

sudo -i -u luc << END

asdf plugin update --all
rustup update stable
npm upgrade -g npm
nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'

END
