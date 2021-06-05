# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
export EDITOR=/bin/nvim
export PAGER=/bin/less

# rust config
. $HOME/.cargo/env
RUST_SRC_PATH="$HOME/.rustup/toolchains/stable-$(arch)-unknown-linux-gnu/lib/rustlib/src/rust/library"

# monero
PATH="$HOME/Crypto/monero-cli:$PATH"

export PATH RUST_SRC_PATH

# asdf config
. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
