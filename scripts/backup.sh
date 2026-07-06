#!/bin/bash
# Fail on any error
set -e

echo "Starting hotel_db backup..."
mkdir -p ./backups

# Dump db using timestamp naming layout
BACKUP_NAME="./backups/backup_$(date +%Y%m%d).sql"
docker exec local_postgres_test pg_dump -U postgres -d hotel_db > "$BACKUP_NAME"

echo "Backup saved to $BACKUP_NAME"
