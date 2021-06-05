#!/bin/sh
# Create symlinks from the home directory to any desired dotfiles in ~/.dotfiles
# and setup a pre-commit hook for updating submodules

dir=~/.dotfiles
olddir=~/.dotfiles_old
# TODO: Add ability to make platform-specific links
files="asdf bash_profile bashrc gitconfig irbrc tool-versions venvs vimrc vim"

echo -e "\n== Creating $olddir for backup of existing dotfiles =="
mkdir -p $olddir

cd $dir

for file in $files; do
    echo -e "\nMoving existing .$file from ~ to $olddir"
    mv -vn ~/.$file $olddir
    echo -e "\nCreating symlink: .$file -> $dir/$file"
    ln -s $dir/$file ~/.$file
done

echo -e "\n== Linking coc settings =="
mkdir -p ~/.config/nvim
ln -s $dir/coc-settings.json ~/.config/nvim/coc-settings.json

echo -e "\n== Setting up pre-commit hook =="
ln -s $dir/submodules.sh .git/hooks/pre-commit

echo -e "\n== Done! =="
