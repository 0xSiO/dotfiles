# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias rm="rm -v"
alias vim=nvim
alias tp="sudo $HOME/.tpoint_fix"
alias tether="sudo create_ap --config .tether_conf"
alias gits="git submodule"

# Neat cheatsheets for developers
cht() {
    curl https://cht.sh/$1
}

# Travis
[ -f /home/luc/.travis/travis.sh ] && source /home/luc/.travis/travis.sh
