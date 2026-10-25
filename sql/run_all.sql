-- run_all.sql
-- Builds the database, runs the data checks and the six business queries.
-- Run from the repo root:
--   psql -U postgres -h localhost -d postgres -o results.txt -f sql/run_all.sql

\set ON_ERROR_STOP on
\pset footer on

\qecho '##### SETUP'
\i sql/01_setup.sql
\qecho '##### DATA QUALITY'
\i sql/02_data_quality.sql
\qecho '##### BUSINESS QUERIES (Q1..Q6 in order)'
\i business_queries.sql
