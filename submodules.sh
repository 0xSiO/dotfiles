#!/bin/bash
# This script generates a .gitmodules file from the plugins in my .vimrc

> .gitmodules

# Vim plugins
grep -oP "^Plugin '\K.+(?=')" vimrc | while read -r line ; do
    plugin=$(grep -oP "\/\K.+" <<< $line)
    echo -e "[submodule \"vim/bundle/$plugin\"]
    path = vim/bundle/$plugin
    url = https://github.com/$line\n" >> .gitmodules
done

git submodule update --init
