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
