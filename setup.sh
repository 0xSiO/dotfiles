#!/bin/bash
# Create symlinks from the home directory to any desired dotfiles in ~/.dotfiles
# and setup a pre-commit hook for updating submodules

dir=~/.dotfiles
olddir=~/.dotfiles_old
files="bashrc bash_profile irbrc pyenv rbenv vimrc vim"

echo -e "\n== Creating $olddir for backup of existing dotfiles =="
mkdir -p $olddir

cd $dir

for file in $files; do
    echo -e "\nMoving existing .$file from ~ to $olddir"
    mv -vn ~/.$file $olddir
    echo -e "\nCreating symlink: .$file -> $dir/$file"
    ln -s $dir/$file ~/.$file
done

echo -e "\n== Setting up pre-commit hook =="
ln -s $dir/submodules.sh .git/hooks/pre-commit

echo -e "\n== Done! =="
