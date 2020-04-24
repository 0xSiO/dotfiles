# luc's dotfiles

`setup.sh` creates the necessary symlinks. Existing dotfiles are backed up to `~/.dotfiles_old`.

Running `sudo bash fedora_kickstart.sh` will perform almost all needed configuration and installation, including
setting up these dotfiles.

Added a new Vim plugin? Make sure it gets registered using `git submodule add [url] vim/bundle/[name]`.
