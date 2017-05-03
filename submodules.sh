#!/bin/bash
# Set up git submodules for Vim plugins, nvm, etc.

# Vim plugins
grep -oP "^Plugin '\K.+(?=')" vimrc | while read -r line ; do
    plugin=$(grep -oP "\/\K.+" <<< $line)
    git submodule add https://github.com/$line vim/bundle/$plugin
done

# nvm
git submodule add https://github.com/creationix/nvm nvm

