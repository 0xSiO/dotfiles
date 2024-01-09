#!/bin/sh
# Use restic to backup important files to external location

BACKUP_LOCATION="/run/media/luc/Seagate Backup+"

if [ ! -d "$BACKUP_LOCATION" ]; then
    echo "Backup location not found: $BACKUP_LOCATION"
    exit 1
fi

echo "Starting backup."
restic -r "$BACKUP_LOCATION" backup --verbose /run/media/luc/F88C2AE88C2AA0DC/Users/Luc/ \
    -e "scoop/persist/steam" \
    -e "scoop/cache" \
    -e "node_modules" \
    -e "target/debug" \
    -e "target/doc" \
    -e "target/release"
