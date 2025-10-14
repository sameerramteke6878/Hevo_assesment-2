# 🚀 HEVO Data Assignment – PostgreSQL → Hevo → Snowflake Pipeline

## 🧠 Overview

This project demonstrates the setup of an end-to-end data pipeline using:

- 🐳 PostgreSQL (Dockerized) as the source  
- 🔄 Hevo Data as the replication and transformation engine  
- ❄️ Snowflake as the destination  

It showcases:
- Logical replication setup  
- ELT/ETL transformations (SQL & Python)  
- Validation in Snowflake  
- Complete documentation for reproducibility  

---

## ⚙️ 1. Steps to Reproduce

### 1.1 Clone the Repository

git clone https://github.com/<username>/hevo-assignment.git  
cd hevo-assignment  

---

### 1.2 Set Up PostgreSQL with Docker

docker-compose up --build  

This will:
- Start a container named hevo_pg  
- Create database hevo_db  
- Run init.sql to create 3 tables (customers, orders, feedback) and load CSV data from the data/ directory  

---

### 1.3 Enable Logical Replication

docker exec -it hevo_pg bash  

vi /var/lib/postgresql/data/postgresql.conf  

Set:
wal_level = logical  
max_wal_senders = 5  
max_replication_slots = 5  

docker restart hevo_pg  

SHOW wal_level;  
-- Output: logical  

---

### 1.4 Expose PostgreSQL for Hevo

ngrok config add-authtoken <your-token>  
ngrok tcp 5432  

Copy forwarding address (tcp://0.tcp.in.ngrok.io:18600) and use it in Hevo PostgreSQL source configuration.  

---

### 1.5 Connect Hevo to Snowflake

Use Partner Connect to link Snowflake to Hevo.  
Database: PC_HEVODATA_DB  
Schema: PUBLIC  

USE SCHEMA PC_HEVODATA_DB.PUBLIC;  
SHOW TABLES;  
SELECT * FROM SNOWFLAKE_ORDERS LIMIT 5;  

---

## 🧩 2. Transformations

### 2.1 SQL Transformations (Hevo Models)

#### a) Order Events

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

#### b) Customers with Username

SELECT  
    *,  
    SPLIT_PART(email, '@', 1) AS username  
FROM SNOWFLAKE_CUSTOMERS;  

---

### 2.2 Python Transformation (Hevo Custom Transformation)

from io.hevo.api import Event  

def transform(event):  
    props = event.getProperties()  
    name  = event.getEventName()  

    if name == 'customers':  
        email = props.get('email') or ''  
        at = email.find('@')  
        if at > 0:  
            props['username'] = email[:at]  

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
            "order_id":    props.get("id"),  
            "customer_id": props.get("customer_id"),  
            "event_type":  event_type,  
            "event_time":  props.get("updated_at") or props.get("created_at")  
        }  

        new_event = Event("order_events", new_props)  
        return [event, new_event]  

    return event  

---

## 📄 3. Assumptions Made

- status stored as VARCHAR instead of ENUM  
- address stored as JSON  
- Timestamp fields optional in CSV  
- ngrok used instead of LocalXpose  
- Default schema: PC_HEVODATA_DB.PUBLIC  

---

## 🧰 4. Choices Made

| Step | Decision | Reason |
|------|-----------|--------|
| Database | PostgreSQL (Docker) | Portable, consistent |
| Replication | Logical (CDC) | Real-time sync |
| Transformations | SQL + Python | Demonstrate ELT & ETL |
| Schema | PUBLIC | Default Hevo schema |
| CSV import | \copy | Reliable bulk load |

---

## ⚠️ 5. Issues & Workarounds

| Issue | Cause | Fix |
|-------|--------|-----|
| Docker permission denied | Daemon not running | Restart Docker |
| Logical replication failed | WAL not set | wal_level=logical |
| ngrok TCP not allowed | Free plan limit | Added card verification |
| Snowflake schema missing | Wrong default | Used PUBLIC schema |
| Hevo model error | DDL not allowed | Removed CREATE TABLE |
| f-string syntax | Hevo Python version | Used concatenation |

---

## 🧪 6. Validation Queries (Snowflake)

SELECT COUNT(*) FROM SNOWFLAKE_CUSTOMERS;  
SELECT COUNT(*) FROM SNOWFLAKE_ORDERS;  
SELECT COUNT(*) FROM SNOWFLAKE_FEEDBACK;  

SELECT email, username FROM SNOWFLAKE_CUSTOMERS LIMIT 5;  

SELECT * FROM ORDER_EVENTS LIMIT 10;  
SELECT DISTINCT event_type FROM ORDER_EVENTS;  

---

## 🎥 7. Loom Video

🎬 Pipeline Demonstration:  
👉 [Add Loom Video Link Here] 👈  

---

## 📦 8. Deliverables

| Deliverable | Description |
|--------------|--------------|
| GitHub Repo | https://github.com/<username>/hevo-assignment |
| Hevo Team Name | <Team Name> |
| Pipeline ID | <Pipeline ID> |
| Documentation | Included in README |
| SQL & Scripts | In transformations/ and validation/ |
| Loom Video | Added above |

---

## 💬 9. Key Learnings

“This assignment taught me how to design, debug, and document a real-time data pipeline.  
From Docker and PostgreSQL configuration to Snowflake integration and Hevo transformations,  
I gained hands-on experience in ETL vs ELT, replication internals, and data warehousing.”

---

## 👨‍💻 Author

Sameer Ramteke  
Hevo Data Assignment – 2025  

---

## ✅ Next Steps

1. Add Loom video link  
2. Commit all files to GitHub  
3. Submit repo link + Hevo details via Google Form  
4. Review everything before interview  
