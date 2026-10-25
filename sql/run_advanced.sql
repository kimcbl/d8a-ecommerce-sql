-- run_advanced.sql
-- Runs the revenue-source comparison and the two advanced queries.
-- Run from the repo root (database already loaded):
--   psql -U postgres -h localhost -d d8a_ecommerce -o results_advanced.txt -f sql/run_advanced.sql

\set ON_ERROR_STOP on

\qecho '##### REVENUE SOURCES'
\i sql/03_revenue_sources.sql
\qecho '##### ADVANCED QUERIES (A1, A2)'
\i advanced_queries.sql
