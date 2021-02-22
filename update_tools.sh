#!/bin/sh
# Update packages, dev tools, vim plugins, etc.

GIT_PULL="git pull origin master"

dnf upgrade -y

sudo -i -u luc << END

rustup update stable

cd ~/.rbenv && $GIT_PULL
cd ~/.rbenv/plugins/ruby-build && $GIT_PULL
cd ~/.pyenv && $GIT_PULL
cd ~/.pyenv/plugins/python-build && $GIT_PULL
cd ~/.nodenv && $GIT_PULL
cd ~/.nodenv/plugins/node-build && $GIT_PULL
npm upgrade -g

nvim --headless +PlugUpgrade +PlugUpdate +qa!

END
