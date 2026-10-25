-- 01_setup.sql
-- Creates the d8a_ecommerce database and loads the four CSV files.
-- Run from the repo root:  psql -U postgres -f sql/01_setup.sql

CREATE DATABASE d8a_ecommerce;
\c d8a_ecommerce

CREATE TABLE customers (id INT, name TEXT, country TEXT, segment TEXT,
  signup_date DATE, email TEXT, phone TEXT);
CREATE TABLE orders (id INT, customer_id INT, order_date DATE,
  status TEXT, total_amount NUMERIC(12,2));
CREATE TABLE products (id INT, name TEXT, category TEXT,
  price NUMERIC(10,2), cost NUMERIC(10,2));
CREATE TABLE order_items (id INT, order_id INT, product_id INT,
  quantity INT, unit_price NUMERIC(10,2));

\copy customers   FROM 'data/customers.csv'   CSV HEADER
\copy orders      FROM 'data/orders.csv'      CSV HEADER
\copy products    FROM 'data/products.csv'    CSV HEADER
\copy order_items FROM 'data/order_items.csv' CSV HEADER

-- Quick check: row counts
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;
