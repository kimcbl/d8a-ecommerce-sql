-- load_data.sql
-- Use this when the tables already exist but are empty:
-- loads the CSVs, then runs the data checks and the six business queries.
-- Run from the repo root:
--   psql -U postgres -h localhost -d d8a_ecommerce -o results.txt -f sql/load_data.sql

\set ON_ERROR_STOP on

\copy customers   FROM 'data/customers.csv'   CSV HEADER
\copy orders      FROM 'data/orders.csv'      CSV HEADER
\copy products    FROM 'data/products.csv'    CSV HEADER
\copy order_items FROM 'data/order_items.csv' CSV HEADER

\i sql/run_queries.sql
