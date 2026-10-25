-- business_queries.sql
-- Six questions from the manager, one query each.
--
-- Rules used in every query (see notes.md):
--   * Duplicates removed: orders are read from (SELECT DISTINCT * FROM orders).
--   * Status is normalised with LOWER(TRIM(status)).
--   * Orders without an amount still count as orders; SUM and AVG skip them.
--   * Customers with a blank country are grouped as 'Unknown'.


-- ============================================================
-- Q1. Who are our 5 best customers?
-- Answer: Our top 5 customers spent $335,295 between them (13% of all completed
--         revenue), led by Sophie Leclerc with $80,762 from just 3 orders.
-- ============================================================
SELECT
    c.id                  AS customer_id,
    c.name                AS customer_name,
    COUNT(*)              AS order_count,
    SUM(o.total_amount)   AS total_revenue
FROM (SELECT DISTINCT * FROM orders) o
JOIN customers c ON c.id = o.customer_id
WHERE LOWER(TRIM(o.status)) = 'completed'
GROUP BY c.id, c.name
ORDER BY total_revenue DESC NULLS LAST
LIMIT 5;


-- ============================================================
-- Q2. How did revenue move month by month in 2024?
-- Answer: 2024 brought in $1.19M; revenue dipped to a low of $66,148 in April, then
--         grew so the second half earned 35% more than the first, peaking at
--         $156,717 in September.
-- ============================================================
SELECT
    TO_CHAR(o.order_date, 'YYYY-MM')     AS month,
    COUNT(*)                             AS order_count,
    SUM(o.total_amount)                  AS total_revenue,
    ROUND(AVG(o.total_amount), 2)        AS avg_order_value
FROM (SELECT DISTINCT * FROM orders) o
WHERE LOWER(TRIM(o.status)) = 'completed'
  AND o.order_date >= DATE '2024-01-01'
  AND o.order_date <  DATE '2025-01-01'
GROUP BY month
ORDER BY month;


-- ============================================================
-- Q3. Which countries bring the revenue?
-- Answer: Revenue is spread evenly across 12 countries, with the USA biggest at 10.9%
--         ($273,428) and USA, Canada and Germany together bringing 29%; customers
--         with no country on file account for 3.5%.
-- ============================================================
SELECT
    -- blank or missing country becomes its own group so the shares add up to 100
    COALESCE(NULLIF(TRIM(c.country), ''), 'Unknown')                 AS country,
    SUM(o.total_amount)                                             AS total_revenue,
    ROUND(100.0 * SUM(o.total_amount) / SUM(SUM(o.total_amount)) OVER (), 2) AS pct_of_total
FROM (SELECT DISTINCT * FROM orders) o
JOIN customers c ON c.id = o.customer_id
WHERE LOWER(TRIM(o.status)) = 'completed'
GROUP BY 1
ORDER BY total_revenue DESC;


-- ============================================================
-- Q4. Are cancellations getting worse?
-- Answer: No: about 9.3 of every 100 orders were cancelled in both 2023 and 2024,
--         and monthly rates swing between 6.3% and 12.9% with no upward trend.
-- ============================================================
SELECT
    TO_CHAR(o.order_date, 'YYYY-MM')                                    AS month,
    COUNT(*)                                                            AS total_orders,
    -- refunds are not cancellations, so only 'cancelled' is counted
    COUNT(*) FILTER (WHERE LOWER(TRIM(o.status)) = 'cancelled')         AS cancelled_orders,
    ROUND(100.0 * COUNT(*) FILTER (WHERE LOWER(TRIM(o.status)) = 'cancelled')
          / COUNT(*), 2)                                                AS cancellation_rate
FROM (SELECT DISTINCT * FROM orders) o
GROUP BY month
ORDER BY month;


-- ============================================================
-- Q5. Do enterprise customers buy differently?
-- Answer: No, the opposite: an enterprise order is worth $691 on average, about 20%
--         less than the $863 of other customers, so Sales' belief is not supported.
-- ============================================================
SELECT
    CASE WHEN LOWER(TRIM(c.segment)) = 'enterprise' THEN 'enterprise' ELSE 'other' END
                                     AS customer_group,
    COUNT(DISTINCT c.id)             AS customer_count,
    COUNT(*)                         AS order_count,
    SUM(o.total_amount)              AS total_revenue,
    ROUND(AVG(o.total_amount), 2)    AS avg_order_value
FROM (SELECT DISTINCT * FROM orders) o
JOIN customers c ON c.id = o.customer_id
WHERE LOWER(TRIM(o.status)) = 'completed'
GROUP BY customer_group
ORDER BY customer_group;


-- ============================================================
-- Q6. Which customers have gone quiet?
-- Answer: 497 past customers have not bought anything since 1 July 2024, and they
--         have been quiet for between 184 and 724 days.
-- ============================================================
SELECT
    c.id                                   AS customer_id,
    c.name                                 AS customer_name,
    MAX(o.order_date)                      AS last_order_date,
    DATE '2024-12-31' - MAX(o.order_date)  AS days_inactive
FROM (SELECT DISTINCT * FROM orders) o
JOIN customers c ON c.id = o.customer_id
WHERE LOWER(TRIM(o.status)) IN ('completed', 'shipped')
GROUP BY c.id, c.name
-- last purchase before 1 July 2024 = no purchase since then
HAVING MAX(o.order_date) < DATE '2024-07-01'
ORDER BY days_inactive DESC, customer_id;
