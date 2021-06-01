#!/bin/sh
# Update .gitmodules from vimrc and other sources

> .gitmodules

# Vim plugins
rg -oP "^\s*Plug '\K.+?(?=')" vimrc | while read -r line ; do
    plugin=$(rg -oP "\/\K.+" <<< $line)
    echo -e "[submodule \"vim/bundle/$plugin\"]
\tpath = vim/bundle/$plugin
\turl = https://github.com/$line\n" >> .gitmodules
done

# asdf
echo -e "[submodule \"asdf\"]
\tpath = asdf
\turl = https://github.com/asdf-vm/asdf\n" >> .gitmodules

git add .gitmodules
