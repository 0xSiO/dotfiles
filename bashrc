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
alias tether="sudo create_ap --config .tether_conf"
alias gits="git submodule"
alias ls="exa --git --group-directories-first -lgh"

# Neat cheatsheets for developers
cht() {
    curl https://cht.sh/$1
}

loadnvm() {
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}

# Travis
[ -f /home/luc/.travis/travis.sh ] && source /home/luc/.travis/travis.sh
