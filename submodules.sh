#!/bin/bash
# Update .gitmodules from vimrc and other sources

> .gitmodules

# Vim plugins
grep -oP "^Plug '\K.+(?=')" vimrc | while read -r line ; do
    plugin=$(grep -oP "\/\K.+" <<< $line)
    echo -e "[submodule \"vim/bundle/$plugin\"]
\tpath = vim/bundle/$plugin
\turl = https://github.com/$line\n" >> .gitmodules
done

# rbenv
echo -e "[submodule \"rbenv\"]
\tpath = rbenv
\turl = https://github.com/rbenv/rbenv\n" >> .gitmodules

# pyenv
echo -e "[submodule \"pyenv\"]
\tpath = pyenv
\turl = https://github.com/pyenv/pyenv\n" >> .gitmodules


git add .gitmodules
