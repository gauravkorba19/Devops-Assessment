# Multi-Environment Infrastructure & Optimized Database Stack

This repository contains a production-oriented DevOps architecture featuring modular multi-environment cloud infrastructure layouts and an optimized local database testing matrix.

## 🛠️ Project Structure
- `infra/modules/`: Reusable architecture blueprints for Network, ECS, and RDS configurations.
- `infra/envs/`: Environment configurations isolating development and production tiers.
- `db/`: Data migrations and database engine initialization layer.
- `scripts/`: System reliability backup and disaster recovery automations.
- `.github/workflows/`: Continuous Integration pipeline automating checks via GitHub Actions.

## 🚀 Local Database Verification Flow

### 1. Initialize and Seed Stack
Spin up the containerized database environment:
```bash
docker compose up -d
```

### 2. Verify Query Optimization Performance
To check index lookup efficiency, enter the active container environment:
```bash
winpty docker exec -it local_postgres_test psql -U postgres -d hotel_db
```
Execute the assessment analytical query string:
```sql
EXPLAIN ANALYZE SELECT org_id, status, COUNT(*), SUM(amount) 
FROM hotel_bookings 
WHERE city = 'delhi' 
AND created_at >= NOW() - INTERVAL '30 days' 
GROUP BY org_id, status;
```
*Performance Metric Verification:* The query planner utilizes an **`Index Only Scan`** via the `idx_hotel_bookings_query_perf` composite index structure, satisfying constraints without reading rows from raw disk space.

### 3. Disaster Recovery Validation
Run the lifecycle automation scripts to verify data backup and restore capabilities:
```bash
./scripts/backup.sh
./scripts/restore.sh
```

## 📈 Index Performance Strategy Explanation
The target analytical count query searches explicitly by filtering elements by `city` and a dynamic timestamp range `created_at`. Creating separate standalone indexes creates an inefficient query plan where the engine must perform two individual bitmap operations and merge them.

Our design choice uses a **Composite Multi-Column Index** `(city, created_at)`. By appending an `INCLUDE (org_id, status, amount)` clause, we convert the entire database matching strategy into a highly optimized **Index Only Scan**. The engine extracts calculations directly from the index nodes without needing to perform slow data block pointer lookups on disk.
