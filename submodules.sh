#!/bin/sh

> .gitmodules

# asdf
cat << END >> .gitmodules
[submodule "asdf"]
    path = asdf
    url = https://github.com/asdf-vm/asdf 
END

# powerlevel10k
cat << END >> .gitmodules
[submodule "powerlevel10k"]
    path = powerlevel10k
    url = https://github.com/romkatv/powerlevel10k
END

git add .gitmodules
