-- This model cleans and standardizes product data.
SELECT
    product_id,
    -- Capitalize product names and categories properly (Title Case).
    INITCAP(product_name) AS product_name,
    INITCAP(category) AS category,
    -- Mark inactive products.
    CASE
        WHEN active_flag = 'N' THEN 'Discontinued Product'
        ELSE product_name
    END AS product_status
FROM
    products_raw
