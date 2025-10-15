# 🚀 HEVO Data Assignment 2 – PostgreSQL → Hevo → Snowflake Pipeline

---

# 🧾 Hevo CXE Assignment — Data Pipeline & Transformations

## 📌 Project Overview

This project demonstrates the end-to-end setup of a **data pipeline from PostgreSQL to Snowflake** using **Hevo Data**.  
The objective is to:
- Connect a source database to Snowflake
- Build a series of transformations to clean and standardize data
- Handle duplicates, nulls, and inconsistent values
- Convert currencies to a standard format (USD)
- Prepare a clean, analytics-ready final model

---

## 📁 Folder Structure

```
hevo-assignment/
├── Dockerfile
├── docker-compose.yml
├── init.sql
├── data/
│   ├── customers_raw.sql       # Original customer data (source)
│   ├── orders_raw.sql          # Original orders data (source)
│   ├── products_raw.sql        # Original product catalog (source)
│   └── country_dim.sql
├── transformations/
│   ├── sql/
│       ├── 01_customer_cleanup.sql   # Deduplication, standardization, and null handling for customer data
│   │   ├── 02_product_standardization.sql  # Standardizes product names and categories
│   │   ├── 03_orders_cleanup.sql     # Cleans orders data, handles duplicates, invalid amounts, and currency conversion
│   │   └── 04_final_unified_dataset.sql
└── README.md
```

---

## ⚙️ 1. Setup Instructions

### 🐳 1.1 Start PostgreSQL using Docker
```bash
docker-compose up --build
```
This creates:
- Database → `postgres`
- Tables → `customers_raw`, `orders_raw`, `products_raw`,`country_dim`
- Loads sample data from the given pdf

---

### 🔐 1.3 Enable Logical Replication
Enter container:
```bash
docker exec -it hevo_pg bash
```
Edit config:
```
vi /var/lib/postgresql/data/postgresql.conf
```
Set:
```
wal_level = logical
max_wal_senders = 5
max_replication_slots = 5
```
Then restart:
```bash
docker restart hevo_pg
```

Check:
```sql
SHOW wal_level;  -- should show "logical"
```

---

### 🌐 1.4 Expose PostgreSQL using Ngrok
```bash
ngrok config add-authtoken <your_token>
ngrok tcp 5432
```

Copy the forwarding address (e.g. `tcp://0.tcp.in.ngrok.io:16916`) → paste into Hevo **PostgreSQL source** config.

---

### ❄️ 1.5 Connect Snowflake in Hevo
-
configured Hevo to connect to the local postgre using grok
---

## 🧩 2. Transformations

### 2.1 SQL Transformations (Hevo Models)

#### 🧱 a) Order Events
`transformations/sql/order_events.sql`
```sql
SELECT
    id AS order_id,
    customer_id,
    CASE
        WHEN LOWER(status) = 'placed' THEN 'order_placed'
        WHEN LOWER(status) = 'shipped' THEN 'order_shipped'
        WHEN LOWER(status) = 'delivered' THEN 'order_delivered'
        WHEN LOWER(status) = 'cancelled' THEN 'order_cancelled'
        ELSE 'unknown_status'
    END AS event_type,
    CURRENT_TIMESTAMP() AS event_time
FROM SNOWFLAKE_ORDERS;
```

#### 👤 b) Customers with Username
`transformations/sql/customers_username.sql`
```sql
SELECT
    *,
    SPLIT_PART(email, '@', 1) AS username
FROM SNOWFLAKE_CUSTOMERS;
```
---

## 🧰 4. Design & Decisions

| Step | Choice | Reason |
|------|---------|--------|
| PostgreSQL via Docker | Easy setup & consistent dev env | Portable |
| Logical Replication | Real-time WAL-based CDC | Reliable |
| Transformations | SQL | Show ELT + ETL |
| Hevo Destination Schema | `PUBLIC` | Default PC schema |


---

## ⚠️ 5. Issues Faced & Fixes

| Issue | Cause | Resolution |
|--------|--------|-------------|
| Docker permission denied | Daemon not running | Restart Docker Desktop |
| WAL level error | Default = replica | Set `wal_level=logical` |
| Ngrok TCP blocked | Free plan limit | Added card for auth |
| “CREATE TABLE not allowed” | Hevo Models allow only SELECT | Used SELECT queries only |

---

## 🧪 6. Validation (Snowflake)
`validation/snowflake_validation.sql`

- select * from finaloutput;
It shows the desired final output.
---

## 🎥 7. Loom Video (Pipeline Demo)
🎬 **Pipeline Walkthrough Video:**  
👉 [Add Loom Video Link Here]

---

## 📦 8. Deliverables

| Deliverable | Description |
|--------------|-------------|
| GitHub Repo | [https://github.com/sameerramteke6878/hevo_assesment-2](https://github.com/sameerramteke6878/hevo_assesment-2) |
| Hevo Team Name | `Sameer` |
| Pipeline ID | `8` |
| SQL DDLs | Inside `transformations/sql/` |
| Validation | Inside `validation/` |
| Loom Video | Link above |

---

## 🧠 9. Key Learnings

> “This project strengthened my understanding of data pipelines, ETL vs ELT, and logical replication.  
> From Docker configuration to Snowflake verification, I learned to debug real-world data flows  
> and document them in a reproducible, professional way.”

---

## 👨‍💻 Author

**Sameer Ramteke**  
Hevo Data Assignment – 2025  

---

