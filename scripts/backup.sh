#!/bin/bash
set -e

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$(dirname "$0")/../backups"
mkdir -p "$BACKUP_DIR"

echo "⚡ Starting secure database backup dump..."
# Create the clean file inside container storage
MSYS_NO_PATHCONV=1 docker exec -t local_postgres_test pg_dump -U postgres -d hotel_db -F c -f "/var/lib/postgresql/data/backup_$TIMESTAMP.dump"

echo "📦 Pulling backup out to host directory..."
# Safely pull that file across the boundary into your local backups/ folder
MSYS_NO_PATHCONV=1 docker cp local_postgres_test:/var/lib/postgresql/data/backup_$TIMESTAMP.dump "$BACKUP_DIR/backup_$TIMESTAMP.dump"

echo "✅ Backup saved successfully: backups/backup_$TIMESTAMP.dump"
