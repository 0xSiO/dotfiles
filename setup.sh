#!/bin/bash
# This script creates symlinks from the home directory to any desired dotfiles in ~/.dotfiles

dir=~/.dotfiles
olddir=~/.dotfiles_old
files="bashrc nvm rbenv venvs vimrc vim"

echo "Creating $olddir for backup of existing dotfiles"
mkdir -p $olddir

cd $dir

for file in $files; do
    echo -e "\nMoving existing .$file from ~ to $olddir"
    mv -vn ~/.$file $olddir
    echo -e "\nCreating symlink: .$file -> $dir/$file"
    ln -s $dir/$file ~/.$file
done
