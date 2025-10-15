-- This model cleans and dedupes customer data.
WITH ranked_customers AS (
    -- Rank records for each customer by update time to find the most recent one.
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY updated_at DESC) as rn
    FROM
        customers_raw
)
SELECT
    customer_id,
    -- Standardize email to lowercase.
    LOWER(email) AS email,
    -- Standardize phone numbers to a 10-digit format or 'Unknown'.
    CASE
        WHEN LENGTH(REGEXP_REPLACE(phone, '[^0-9]', '')) = 10 THEN REGEXP_REPLACE(phone, '[^0-9]', '')
        ELSE 'Unknown'
    END AS phone,
    -- Standardize country codes using the dimension table.
    COALESCE(cd.iso_code, 'Unknown') AS country_code,
    -- Replace null created_at with a default timestamp.
    COALESCE(created_at, '1900-01-01 00:00:00') AS created_at,
    updated_at,
    -- Mark customers with all null records as 'Invalid Customer'.
    CASE
        WHEN customer_id IS NOT NULL AND email IS NULL AND phone IS NULL AND country_code IS NULL THEN 'Invalid Customer'
        ELSE 'Valid'
    END AS customer_status
FROM
    ranked_customers rc
LEFT JOIN
    country_dim cd ON UPPER(rc.country_code) = UPPER(cd.iso_code) OR UPPER(rc.country_code) = UPPER(cd.country_name)
WHERE
    rn = 1 -- Keep only the most recent record for each customer.
