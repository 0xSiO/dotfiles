# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
alias rm="rm -v"
alias vi=vim
alias vim=nvim
alias tp="sudo $HOME/.tpoint_fix"
alias tether="sudo create_ap --config .tether_conf"
alias gits="git submodule"

# rbenv config
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# nvm config
export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH="$NVM_DIR/versions/node/v7.9.0/bin:$PATH"
export PATH="$NVM_DIR/versions/node//bin:$PATH"
export PATH="$NVM_DIR/versions/node/v7.9.0/bin:$PATH"
