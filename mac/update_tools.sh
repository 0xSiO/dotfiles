#!/bin/sh
# Update packages, dev tools, etc.

brew upgrade --greedy
asdf plugin update --all
rustup update stable
pip install -U poetry pynvim
