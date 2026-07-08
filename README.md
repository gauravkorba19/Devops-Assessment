# DevOps Assessment: Terraform & Database Reliability

A practical DevOps implementation featuring modular AWS multi-environment infrastructure using Terraform, a containerized local database test bench, query performance tuning, and automated backup/restore scripts.

---

##  Project Structure

This repository separates our infrastructure code from local database testing and operational scripts:

```text
├── .github/workflows/  # CI/CD pipelines to validate Terraform on Pull Requests
├── infra/              # AWS infrastructure managed via Terraform
│   ├── modules/        # Reusable resource modules (Network, ECS, RDS)
│   └── envs/           # Environment setups (Dev & Prod)
├── db/                 # Database initialization schemas and baseline seed data
└── scripts/            # Shell scripts for database backups and restoration
```

### Folder Breakdown
* **.github/workflows/**: Automatically runs code formatting checks, initialization validations, and execution plans on every Pull Request.
* **infra/**: Holds our core network setup, container routing, and database infrastructure configs.
* **db/**: Contains the baseline schemas and mock datasets used to spin up a local instance quickly.
* **scripts/**: Quick utility scripts to handle manual or scheduled database backups and recoveries.

---

##  Database Setup & Optimization

### 1. Schema Design Choice
# Schema Design: Why We Omit `IF NOT EXISTS`
The schema intentionally avoids `IF NOT EXISTS` to ensure reliable, predictable automated migrations. Excluding this clause forces a hard failure if a table already exists in an unexpected state, avoiding hidden "success" results where applications fail due to inconsistent data structures.

* **Catching State Drift:** If a table already exists locally or in an environment with outdated or modified columns, `IF NOT EXISTS` will silently skip it.
* **Failing Loudly:** Leaving it out ensures the migration script fails instantly if there is an environmental collision, prompting the engineer to fix the underlying state issue.

### 2. Query Optimization & Indexing Strategy
To speed up the analytics query that tracks bookings by city and date, I implemented a multi-column composite B-Tree index:

```sql
CREATE INDEX idx_hotel_bookings_query_perf 
ON hotel_bookings (city, created_at, org_id, status, amount);
```

#### Why this index was chosen:
* **Efficient Filtering:** The database engine scans the index from left to right, instantly filtering by `city` and `created_at` matching the query's `WHERE` clause.
* **Index Only Scan:** Because `org_id`, `status`, and `amount` are also included in the index tree, the database can fetch and calculate the counts and sums entirely from memory. It completely skips reading the heavy table data from disk, which massively reduces disk I/O.

---

## ⚡ How to Run and Verify Locally

Follow these quick steps to spin up the local environment and test the workflow.

### Step 1: Spin up the DB container
Run the Postgres container in the background:
```bash
docker compose up -d
```

### Step 2: Check query performance
Log into your local Postgres instance to check if the index is working:
```bash
docker exec -it local_postgres_test psql -U postgres -d hotel_db
```
Run an `EXPLAIN ANALYZE` on the analytics query to check the execution pathway:
```sql
EXPLAIN ANALYZE 
SELECT org_id, status, COUNT(*), SUM(amount) 
FROM hotel_bookings 
WHERE city = 'delhi' 
  AND created_at >= NOW() - INTERVAL '30 days' 
GROUP BY org_id, status;
```
*(You should see the query planner utilizing an **Index Only Scan** instead of a Sequential Scan).*

### Step 3: Test the Backup & Restore scripts
Make the scripts executable and run them back-to-back:
```bash
chmod +x scripts/*.sh
./scripts/backup.sh
./scripts/restore.sh
```

#### How to verify it worked:
1. Check that the backup script successfully creates a timestamped `.sql` file without errors.
2. Log back into your database and check the row counts to make sure all seed records survived the wipe and restore:
   ```sql
   SELECT COUNT(*) FROM hotel_bookings; -- Should return the baseline 100+ rows
   ```

---

## 🚀 Multi-Environment AWS Setup

The Terraform setup uses clean module variables to keep our environments isolated and sized appropriately.

```text
Internet ──> Application Load Balancer ──> ECS Fargate (Private) ──> RDS PostgreSQL (Private)
```

### Environment Configurations

| Setting | Dev Environment | Prod Environment |
| :--- | :--- | :--- |
| **Instance Sizing** | Small instances to keep costs low | Larger instances for production workloads |
| **Deletion Protection** | Turned off for easy teardown | Turned on to prevent accidental database deletion |
| **Backup Retention** | Short retention lifecycle (7 Days) | Longer rolling backup retention (30 Days) |
| **Network Layout** | Standard private subnets | Multi-AZ setup with automated failover endpoints |

---
