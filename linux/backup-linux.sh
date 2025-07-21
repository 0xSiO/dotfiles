#!/bin/sh
# Use restic to backup important files to external location

BACKUP_LOCATION="/run/media/luc/Seagate Backup+"

if [ ! -d "$BACKUP_LOCATION" ]; then
    echo "Backup location not found: $BACKUP_LOCATION"
    exit 1
fi

echo "Starting backup."
restic -r "$BACKUP_LOCATION" backup --verbose ~/ \
    -e ~/.local/share/Trash \
    -e ~/.local/share/containers \
    -e ~/.cache \
    -e ~/.cargo \
    -e ~/.gradle \
    -e ~/.npm \
    -e ~/.rustup \
    -e ~/.var \
    -e ~/.venvs \
    -e "node_modules" \
    -e "target/debug" \
    -e "target/doc" \
    -e "target/release" \
    -e ~/MEGA/Characters \
    -e ~/MEGA/Documents \
    -e ~/MEGA/Exports \
    -e ~/Downloads/Vault
