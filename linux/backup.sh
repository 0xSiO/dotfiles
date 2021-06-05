#!/bin/sh
# Use restic to backup important files to external location

BACKUP_LOCATION="/run/media/luc/Seagate"
# BACKUP_LOCATION="/home/luc/pCloudDrive"
REPO_NAME="Backup"

if [ ! -d "$BACKUP_LOCATION" ]; then
    echo "Backup location not found: $BACKUP_LOCATION"
    exit 1
fi

if [ ! -d "$BACKUP_LOCATION/$REPO_NAME" ]; then
    echo "Repository '$REPO_NAME' not found, creating one."
    restic -r "$BACKUP_LOCATION/$REPO_NAME" init
fi

if [ ! $? -eq 0 ]; then
    echo "Creating repository failed."
    exit 2
fi

echo "Starting backup."
restic -r "$BACKUP_LOCATION/$REPO_NAME" backup --verbose \
    -e ~/Downloads -e ~/MEGA -e ~/.local/share/Trash -e ~/.local/share/containers \
    -e ~/.pcloud -e ~/.cache -e ~/.rustup -e ~/.cargo \
    ~/
