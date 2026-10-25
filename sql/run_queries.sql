-- run_queries.sql
-- Use this when d8a_ecommerce already exists and is loaded:
-- it skips the setup and runs the data checks and the six business queries.
-- Run from the repo root:
--   psql -U postgres -h localhost -d d8a_ecommerce -o results.txt -f sql/run_queries.sql

\set ON_ERROR_STOP on

\qecho '##### ROW COUNTS (expected: customers 1200, orders 5020, products 200, order_items 9423)'
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'orders',      COUNT(*) FROM orders
UNION ALL SELECT 'products',    COUNT(*) FROM products
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;

\qecho '##### DATA QUALITY'
\i sql/02_data_quality.sql
\qecho '##### BUSINESS QUERIES (Q1..Q6 in order)'
\i business_queries.sql
