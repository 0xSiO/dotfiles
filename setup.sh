#!/bin/sh
# Create symlinks from the home directory to any desired dotfiles in ~/.dotfiles
# and setup a pre-commit hook for updating submodules

dir=~/.dotfiles
old_dir=~/.dotfiles.old
platform=$1

[ -z "$platform" ] && echo "Usage: $0 [platform]" && exit 1
[ -d "$old_dir" ]  && echo "Setup has already ran. Delete $old_dir and try again." && exit 2

section() {
    echo
    echo "== $1 =="
}

# Usage: link target link_name
# Result:
#   move link_name -> $old_dir/link_name (if exists)
#   add  link_name -> target 
link() {
    [ -e "$2" ] && mv -n $2 $old_dir && echo "backed up old $2 to $old_dir"
    ln -s $1 $2
}

section "Setting up $platform-specific files"
case $platform in
    linux)
        platform_files="gitconfig p10k.zsh tool-versions zshrc"
        ;;
    mac)
        platform_files="gitconfig p10k.zsh tool-versions zshrc"
        ;;
    *)
        echo "Unsupported platform: $platform"
        exit 3
        ;;
esac

mkdir -pv $old_dir

for file in $platform_files; do
    echo "linking ~/.$file to $dir/$platform/$file"
    link $dir/$platform/$file ~/.$file
done

section "Setting up common files"
common_files="irbrc venvs"

for file in $common_files; do
    echo "linking ~/.$file to $dir/$file"
    link $dir/$file ~/.$file
done

coc_config=~/.config/nvim/coc-settings.json
mpv_config=~/.config/mpv
vim_config=~/.config/nvim/init.lua
mkdir -p ~/.config/nvim
echo "linking $coc_config to $dir/coc-settings.json"
link $dir/coc-settings.json $coc_config
echo "linking $mpv_config to $dir/mpv"
link $dir/mpv $mpv_config
echo "linking $vim_config to $dir/init.lua"
link $dir/init.lua $vim_config

section "Setting up pre-commit hook"
ln -sf $dir/submodules.sh $dir/.git/hooks/pre-commit

section "Done!"
