# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]
then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

alias rm="rm -v"
alias vim=nvim
alias tether="sudo create_ap --config .tether_conf"
alias gits="git submodule"
alias ls="exa --git --group-directories-first -lgh"
alias update="sudo ~/.dotfiles/update_tools.sh"
alias backup="~/.dotfiles/backup.sh"

# Neat cheatsheets for developers
cht() {
    curl https://cht.sh/$1
}
