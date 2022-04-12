#!/bin/sh
# Use restic to backup important files to external location

BACKUP_LOCATION="/Volumes/GoogleDrive/My Drive"
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
restic -r "$BACKUP_LOCATION/$REPO_NAME" backup --verbose ~/ \
    --exclude ".Trash" \
    --exclude '.asdf' \
    --exclude '.cache' \
    --exclude '.cargo' \
    --exclude ".npm" \
    --exclude '.rustup' \
    --exclude '.zsh_sessions' \
    --exclude "Library/Containers/com.docker.docker" \
    --exclude "Library/Application Support/Google" \
    --exclude "Library/Application Support/Slack" \
    --exclude "Library/Application Support/Firefox/Profiles/yrs8jrej.default-release/storage/default" \
    --exclude "Library/Caches" \
    --exclude "Library/News" \
    --exclude "node_modules" \
    --exclude ".terragrunt-cache"
