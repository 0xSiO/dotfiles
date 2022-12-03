#!/bin/sh
# Use restic to backup important files to external location

BACKUP_LOCATION="/run/media/luc/Seagate Backup+"
# BACKUP_LOCATION="/home/luc/pCloudDrive"

if [ ! -d "$BACKUP_LOCATION" ]; then
    echo "Backup location not found: $BACKUP_LOCATION"
    exit 1
fi

echo "Starting backup."
restic -r "$BACKUP_LOCATION" backup --verbose ~/ \
    -e ~/pCloudDrive \
    -e ~/.local/share/Trash \
    -e ~/.local/share/containers \
    -e ~/.local/share/JetBrains \
    -e ~/.asdf \
    -e ~/.cache \
    -e ~/.cargo \
    -e ~/.gradle \
    -e ~/.npm \
    -e ~/.pcloud \
    -e ~/.rustup \
    -e "node_modules" \
    -e "target/debug" \
    -e "target/doc" \
    -e "target/release"
