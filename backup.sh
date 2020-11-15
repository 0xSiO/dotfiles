#!/bin/bash
# Use restic to backup important files to external hard drive

BACKUP_LOCATION="/run/media/luc/Seagate"
REPO_NAME="Backup"

if [ ! -d "$BACKUP_LOCATION" ]; then
    echo "Backup location not found: $BACKUP_LOCATION"
    exit 1
fi

if [ ! -d "$BACKUP_LOCATION/$REPO_NAME" ]; then
    echo "Repository '$REPO_NAME' not found, creating one."
    restic -r $BACKUP_LOCATION/$REPO_NAME init
fi

if [ ! $? -eq 0 ]; then
    echo "Creating repository failed."
    exit 2
fi

echo "Starting backup."
restic -r $BACKUP_LOCATION/$REPO_NAME backup --verbose \
    ~/Development ~/Music ~/Pictures ~/docker-compose.yml
