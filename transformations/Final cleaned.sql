-- This final model joins all cleaned tables to create a unified dataset.
SELECT
    o.order_id,
    o.created_at AS order_date,
    o.amount,
    o.currency,
    o.amount_usd,
    -- Handle orphan customers.
    COALESCE(c.customer_id, o.customer_id) AS customer_id,
    CASE
        WHEN c.customer_status = 'Invalid Customer' THEN 'Invalid Customer'
        WHEN c.customer_id IS NULL THEN 'Orphan Customer'
        ELSE c.email
    END AS customer_email,
    -- Handle unknown and discontinued products.
    COALESCE(p.product_id, o.product_id, 'Unknown') AS product_id,
    CASE
        WHEN p.product_status = 'Discontinued Product' THEN 'Discontinued Product'
        WHEN p.product_id IS NULL THEN 'Unknown Product'
        ELSE p.product_name
    END AS product_name,
    p.category AS product_category
FROM
    orders_cleaned o
LEFT JOIN
    customers_cleaned c ON o.customer_id = c.customer_id
LEFT JOIN
    products_cleaned p ON o.product_id = p.product_id
ORDER BY
    o.order_id
