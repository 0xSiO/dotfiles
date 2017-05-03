#!/bin/bash
# Update .gitmodules from vimrc and other sources

> .gitmodules

# Vim plugins
grep -oP "^Plugin '\K.+(?=')" vimrc | while read -r line ; do
    plugin=$(grep -oP "\/\K.+" <<< $line)
    echo -e "[submodule \"vim/bundle/$plugin\"]
\tpath = vim/bundle/$plugin
\turl = https://github.com/$line\n" >> .gitmodules
done

# nvm
echo -e "[submodule \"nvm\"]
\tpath = nvm
\turl = https://github.com/creationix/nvm\n" >> .gitmodules

# rbenv
echo -e "[submodule \"rbenv\"]
\tpath = rbenv
\turl = https://github.com/rbenv/rbenv\n" >> .gitmodules
