CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    address JSON
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id),
    status VARCHAR(50)
);

CREATE TABLE feedback (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id),
    feedback_comment TEXT,
    rating INT
);

\copy customers(id, first_name, last_name, email, address) FROM '/data/customers.csv' DELIMITER ',' CSV HEADER;
\copy orders(id, customer_id, status) FROM '/data/orders.csv' DELIMITER ',' CSV HEADER;
\copy feedback(id, order_id, feedback_comment, rating) FROM '/data/feedback.csv' DELIMITER ',' CSV HEADER;
