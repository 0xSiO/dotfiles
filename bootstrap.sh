#!/usr/bin/env bash
set -euo pipefail

if command -v dnf &>/dev/null; then
    sudo dnf install -y ansible
elif command -v brew &>/dev/null; then
    brew install ansible git
else
    echo "Unsupported platform. Install Ansible manually and re-run."
    exit 1
fi

DOTFILES_DIR="$HOME/.dotfiles"

if [ ! -d "$DOTFILES_DIR" ]; then
    git clone https://github.com/0xSiO/dotfiles "$DOTFILES_DIR"
fi

cd "$DOTFILES_DIR"
ansible-galaxy collection install -r requirements.yml
ansible-playbook playbooks/site.yml -JK
