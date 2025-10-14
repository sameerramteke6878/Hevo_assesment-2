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
