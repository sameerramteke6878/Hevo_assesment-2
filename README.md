# 🚀 HEVO Data Assignment – PostgreSQL → Hevo → Snowflake Pipeline

---

## 🧭 Project Overview

This project demonstrates a complete **data engineering pipeline** built using:

- 🐳 **PostgreSQL (Docker)** → as the data source  
- 🔄 **Hevo Data** → for data replication and transformations  
- ❄️ **Snowflake** → as the cloud data warehouse destination  

It includes Docker setup, data ingestion from CSVs, transformation logic (SQL + Python), and validation queries.

---

## 📁 Folder Structure

```
hevo-assignment/
├── Dockerfile
├── docker-compose.yml
├── init.sql
├── data/
│   ├── customers.csv
│   ├── orders.csv
│   ├── feedback.csv
├── transformations/
│   ├── hevo_python_transform.py
│   ├── sql/
│       ├── order_events.sql
│       ├── customers_username.sql
├── validation/
│   ├── snowflake_validation.sql
└── README.md
```

---

## ⚙️ 1. Setup Instructions

### 🧩 1.1 Clone Repository
```bash
git clone https://github.com/<username>/hevo-assignment.git
cd hevo-assignment
```

---

### 🐳 1.2 Start PostgreSQL using Docker
```bash
docker-compose up --build
```
This creates:
- Database → `hevo_db`
- Tables → `customers`, `orders`, `feedback`
- Loads sample data from `data/` CSV files

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

Copy the forwarding address (e.g. `tcp://0.tcp.in.ngrok.io:18600`) → paste into Hevo **PostgreSQL source** config.

---

### ❄️ 1.5 Connect Snowflake in Hevo
- Database: `PC_HEVODATA_DB`
- Schema: `PUBLIC`
- Validate connection:
```sql
USE SCHEMA PC_HEVODATA_DB.PUBLIC;
SHOW TABLES;
SELECT * FROM SNOWFLAKE_ORDERS LIMIT 5;
```

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

### 2.2 Python Transformation (Hevo Custom Script)
`transformations/hevo_python_transform.py`
```python
from io.hevo.api import Event

def transform(event):
    props = event.getProperties()
    name  = event.getEventName()

    # Derive username from email
    if name == 'customers':
        email = props.get('email') or ''
        at = email.find('@')
        if at > 0:
            props['username'] = email[:at]

    # Generate order event rows
    if name == 'orders':
        status = (props.get('status') or '').strip().lower()
        mapping = {
            'placed': 'order_placed',
            'shipped': 'order_shipped',
            'delivered': 'order_delivered',
            'cancelled': 'order_cancelled'
        }
        event_type = mapping.get(status, 'unknown_status')

        new_props = {
            "order_id": props.get("id"),
            "customer_id": props.get("customer_id"),
            "event_type": event_type,
            "event_time": props.get("updated_at") or props.get("created_at")
        }

        new_event = Event("order_events", new_props)
        return [event, new_event]

    return event
```

---

## 📄 3. Assumptions Made

- `status` column stored as `VARCHAR` (not ENUM) for flexibility  
- `address` stored as JSON for future expansion  
- CSVs contain header rows  
- `updated_at`/`created_at` may be missing (optional)  
- Using `PUBLIC` schema in Snowflake  

---

## 🧰 4. Design & Decisions

| Step | Choice | Reason |
|------|---------|--------|
| PostgreSQL via Docker | Easy setup & consistent dev env | Portable |
| Logical Replication | Real-time WAL-based CDC | Reliable |
| Transformations | SQL + Python mix | Show ELT + ETL |
| Hevo Destination Schema | `PUBLIC` | Default PC schema |
| CSV Load | `\copy` command | Fast & simple |

---

## ⚠️ 5. Issues Faced & Fixes

| Issue | Cause | Resolution |
|--------|--------|-------------|
| Docker permission denied | Daemon not running | Restart Docker Desktop |
| WAL level error | Default = replica | Set `wal_level=logical` |
| Ngrok TCP blocked | Free plan limit | Added card for auth |
| Schema not found | Wrong schema | Used `PC_HEVODATA_DB.PUBLIC` |
| f-string syntax error | Hevo runtime Python 3.6 | Used string concatenation |
| “CREATE TABLE not allowed” | Hevo Models allow only SELECT | Used SELECT queries only |

---

## 🧪 6. Validation (Snowflake)
`validation/snowflake_validation.sql`

```sql
-- Row Counts
SELECT COUNT(*) FROM SNOWFLAKE_CUSTOMERS;
SELECT COUNT(*) FROM SNOWFLAKE_ORDERS;
SELECT COUNT(*) FROM SNOWFLAKE_FEEDBACK;

-- Username Verification
SELECT email, username FROM SNOWFLAKE_CUSTOMERS LIMIT 5;

-- Event Validation
SELECT * FROM ORDER_EVENTS LIMIT 10;
SELECT DISTINCT event_type FROM ORDER_EVENTS;
```

---

## 🎥 7. Loom Video (Pipeline Demo)
🎬 **Pipeline Walkthrough Video:**  
👉 [Add Loom Video Link Here]

---

## 📦 8. Deliverables

| Deliverable | Description |
|--------------|-------------|
| GitHub Repo | [https://github.com/<username>/hevo-assignment](https://github.com/<username>/hevo-assignment) |
| Hevo Team Name | `<Team Name>` |
| Pipeline ID | `<Pipeline ID>` |
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
Guided by **Rupam Jengthe**

---

## ✅ Next Steps

1. Add Loom video link 🎥  
2. Commit all final files  
3. Push to GitHub  
4. Submit repo + Hevo details in Google Form  
