#!/bin/sh

> .gitmodules

# powerlevel10k
cat << END >> .gitmodules
[submodule "powerlevel10k"]
    path = powerlevel10k
    url = https://github.com/romkatv/powerlevel10k
END

git add .gitmodules
