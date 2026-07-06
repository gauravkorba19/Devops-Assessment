#!/bin/bash
set -e

# Check if a backup file argument was passed
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_backup_file.sql>"
    echo "Example: $0 ./backups/backup_20260707.sql"
    exit 1
fi

BACKUP_FILE=$1

# Quick validation check
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file '$BACKUP_FILE' not found."
    exit 1
fi

echo "Terminating existing connections to hotel_db..."
docker exec -i local_postgres_test psql -U postgres -d postgres -c \
    "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'hotel_db' AND pid <> pg_backend_pid();"

echo "Recreating a clean hotel_db database..."
docker exec -i local_postgres_test psql -U postgres -d postgres -c "DROP DATABASE IF EXISTS hotel_db;"
docker exec -i local_postgres_test psql -U postgres -d postgres -c "CREATE DATABASE hotel_db;"

echo "Restoring database from: $BACKUP_FILE ..."
docker exec -i local_postgres_test psql -U postgres -d hotel_db < "$BACKUP_FILE"

echo "Database restore completed successfully."
