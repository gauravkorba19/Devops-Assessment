#!/bin/bash
set -e

BACKUP_DIR="$(dirname "$0")/../backups"
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/*.dump 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
  echo "❌ Error: No valid backup snapshot file (.dump) found inside local backups folder."
  exit 1
fi

echo "🔄 Tearing down existing infrastructure and data..."
docker compose down -v
docker compose up -d postgres

echo "⏳ Waiting for database container to initialize..."
sleep 10

echo "📦 Transferring backup artifact..."
# Push it back to the temporary folder inside the new container instance
MSYS_NO_PATHCONV=1 docker cp "$LATEST_BACKUP" local_postgres_test:/tmp/restore.dump

echo "⚡ Restoring database from snapshot..."
MSYS_NO_PATHCONV=1 docker exec -i local_postgres_test pg_restore -U postgres -d hotel_db --clean --no-owner /tmp/restore.dump
echo "✅ Recovery operation successfully completed!"
