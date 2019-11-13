#!/bin/bash
# Update packages, dev tools, vim plugins, etc.

GIT_PULL="git pull origin master"

echo $(date)

dnf upgrade -y

# Update rust, rbenv, yarn, and vim plugins
sudo -i -u luc << END

rustup update stable

cd ~/.rbenv && $GIT_PULL && cd plugins/ruby-build && $GIT_PULL
cd ~/.pyenv && $GIT_PULL

yarn global upgrade

nvim --headless +PlugUpgrade +PlugUpdate +qa!

# This is very resource-intensive, only run when needed
# cd ~/.dotfiles/vim/bundle/YouCompleteMe
# ./install.py --clang-completer --rust-completer --js-completer --java-completer

END
