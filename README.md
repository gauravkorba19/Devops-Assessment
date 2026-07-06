# devops-assessment

Internal DevOps framework assessment covering Terraform infrastructure modules, PostgreSQL index profiling, and backup scripts.

## Project Structure
* `infra/` - Terraform configuration files (VPC, ECS, RDS)
* `db/` - DB initialization and test data migrations
* `scripts/` - Shell automations for backup/restore processes

## Getting Started

### 1. Spin up the DB locally
```bash
docker compose up -d
```

### 2. Verify Database Performance
Connect to the database instance to run performance profiling checks:
```bash
# Windows users might need 'winpty' prefix
docker exec -it local_postgres_test psql -U postgres -d hotel_db
```

Run the analytics query to check index usage:
```sql
EXPLAIN ANALYZE 
SELECT org_id, status, COUNT(*), SUM(amount) 
FROM hotel_bookings 
WHERE city = 'delhi' 
  AND created_at >= NOW() - INTERVAL '30 days' 
GROUP BY org_id, status;
```
*Note: The planner uses an Index Only Scan via `idx_hotel_bookings_query_perf` to skip direct disk reads.*

### 3. Test Backups
```bash
chmod +x scripts/*.sh
./scripts/backup.sh
./scripts/restore.sh
```
