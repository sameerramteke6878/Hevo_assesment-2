-- This model cleans order data, handles invalid values, and converts currency.
WITH amount_median AS (
    -- Calculate the median amount per customer to fill in nulls.
    SELECT
        customer_id,
        MEDIAN(amount) AS median_customer_amount
    FROM
        orders_raw
    WHERE
        amount IS NOT NULL AND amount >= 0
    GROUP BY
        customer_id
)
SELECT DISTINCT -- Remove exact duplicate order rows.
    o.order_id,
    o.customer_id,
    o.product_id,
    -- Standardize currency codes to uppercase.
    UPPER(o.currency) AS currency,
    -- Handle invalid and null amounts.
    COALESCE(
        CASE WHEN o.amount < 0 THEN 0 ELSE o.amount END,
        am.median_customer_amount,
        0 -- Final fallback if a customer has no valid orders.
    ) AS amount,
    -- Create a derived column for amount in USD.
    (COALESCE(
        CASE WHEN o.amount < 0 THEN 0 ELSE o.amount END,
        am.median_customer_amount,
        0
    )) *
    CASE UPPER(o.currency)
        WHEN 'USD' THEN 1
        WHEN 'INR' THEN 1/83
        WHEN 'SGD' THEN 1/1.35
        WHEN 'EUR' THEN 1/0.92
        ELSE 1 -- Assuming default is USD if currency is unknown
    END AS amount_usd,
    o.created_at
FROM
    orders_raw o
LEFT JOIN
    amount_median am ON o.customer_id = am.customer_id
