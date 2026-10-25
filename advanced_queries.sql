-- advanced_queries.sql
-- Two follow-up questions that use window functions.
--
-- Same rules as business_queries.sql (see notes.md):
--   * Duplicates removed: orders are read from (SELECT DISTINCT * FROM orders).
--   * Status is normalised with LOWER(TRIM(status)).
--
-- Revenue source:
--   * A1 is a product question, so revenue = SUM(quantity * unit_price) from order_items.
--   * A2 is an order question, so revenue = SUM(total_amount) from orders.
--   The two sources do not add up to the same total (see notes.md).


-- ============================================================
-- A1. What are the 3 best-selling products in each category?
-- Answer: Desk Model 85 is by far our best seller with $1.48M in sales, more than twice
--         the next product (Charger Model 180, $647,520), and in 5 of the 10 categories
--         the number 1 product sells at least twice as much as the number 2.
-- ============================================================
WITH product_revenue AS (
    SELECT
        p.category,
        p.name                              AS product_name,
        SUM(oi.quantity * oi.unit_price)    AS revenue
    -- joining the de-duplicated orders keeps a copied order from counting its lines twice
    FROM (SELECT DISTINCT * FROM orders) o
    JOIN order_items oi ON oi.order_id = o.id
    JOIN products p     ON p.id = oi.product_id
    WHERE LOWER(TRIM(o.status)) = 'completed'
    GROUP BY p.category, p.name
),
ranked AS (
    SELECT
        category,
        product_name,
        revenue,
        ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC, product_name) AS rank_in_category
    FROM product_revenue
)
SELECT category, product_name, revenue, rank_in_category
FROM ranked
WHERE rank_in_category <= 3
ORDER BY category, rank_in_category;


-- ============================================================
-- A2. How does revenue change from one month to the next?
-- Answer: Revenue jumps around a lot from month to month, from a 40.7% drop in October
--         2024 to a 110.5% rise in June 2023, and over the full year 2024 brought in
--         9.3% less than 2023 ($1.19M against $1.31M).
-- ============================================================
WITH monthly AS (
    SELECT
        TO_CHAR(o.order_date, 'YYYY-MM')    AS month,
        SUM(o.total_amount)                 AS total_revenue
    FROM (SELECT DISTINCT * FROM orders) o
    WHERE LOWER(TRIM(o.status)) = 'completed'
    GROUP BY month
)
SELECT
    month,
    total_revenue,
    -- the first month has no previous month, so LAG returns NULL there
    LAG(total_revenue) OVER (ORDER BY month)                          AS prev_month_revenue,
    ROUND(100.0 * (total_revenue - LAG(total_revenue) OVER (ORDER BY month))
          / LAG(total_revenue) OVER (ORDER BY month), 2)              AS mom_growth_pct
FROM monthly
ORDER BY month;
