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

starship_config=~/.config/starship.toml
echo "linking $starship_config to $dir/$platform/starship.toml"
link $dir/$platform/starship.toml $starship_config

section "Setting up common files"
common_files="asdf irbrc venvs vimrc vim"

for file in $common_files; do
    echo "linking ~/.$file to $dir/$file"
    link $dir/$file ~/.$file
done

coc_config=~/.config/nvim/coc-settings.json
echo "linking $coc_config to $dir/coc-settings.json"
mkdir -p ~/.config/nvim
link $dir/coc-settings.json $coc_config

section "Setting up pre-commit hook"
ln -sf $dir/submodules.sh $dir/.git/hooks/pre-commit

section "Done!"
