SELECT
    *,
    SPLIT_PART(email, '@', 1) AS username
FROM SNOWFLAKE_CUSTOMERS;
