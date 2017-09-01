# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH="$PATH:$HOME/.local/bin:$HOME/bin"

# rbenv config
PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# nvm config
NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
PATH="$NVM_DIR/versions/node/v8.4.0/bin:$PATH"

# rust config
PATH="$HOME/.cargo/bin:$PATH"
RUST_SRC_PATH="$HOME/.multirust/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src"

export PATH NVM_DIR RUST_SRC_PATH

# TTY solarized color scheme
if [ "$TERM" = "linux" ]; then
    echo -en "\e]P0073642" #black
    echo -en "\e]P1dc322f" #darkgrey
    echo -en "\e]P2859900" #darkred
    echo -en "\e]P3b58900" #red
    echo -en "\e]P4268bd2" #darkgreen
    echo -en "\e]P5d33682" #green
    echo -en "\e]P62aa198" #brown
    echo -en "\e]P7eee8d5" #yellow
    echo -en "\e]P8002b36" #darkblue
    echo -en "\e]P9cb4b16" #blue
    echo -en "\e]PA586e75" #darkmagenta
    echo -en "\e]PB657b83" #magenta
    echo -en "\e]PC839496" #darkcyan
    echo -en "\e]PD6c71c4" #cyan
    echo -en "\e]PE93a1a1" #lightgrey
    echo -en "\e]PFfdf6e3" #white
    clear #for background artifacting
fi
