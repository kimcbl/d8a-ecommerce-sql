-- 03_revenue_sources.sql
-- Compares the two revenue sources for completed orders:
-- orders.total_amount (order questions) and quantity * unit_price from order_items (product questions).

WITH completed AS (
    SELECT DISTINCT *
    FROM orders
    WHERE LOWER(TRIM(status)) = 'completed'
),
lines AS (
    SELECT order_id, SUM(quantity * unit_price) AS items_revenue
    FROM order_items
    GROUP BY order_id
)
SELECT
    SUM(c.total_amount)                                         AS revenue_from_orders,
    SUM(l.items_revenue)                                        AS revenue_from_order_items,
    SUM(l.items_revenue) - SUM(c.total_amount)                  AS difference,
    COUNT(*)                                                    AS completed_orders,
    COUNT(*) FILTER (WHERE l.order_id IS NULL)                  AS orders_without_lines,
    COUNT(*) FILTER (WHERE c.total_amount IS NULL)              AS orders_without_amount,
    COUNT(*) FILTER (WHERE c.total_amount <> l.items_revenue)   AS orders_where_sources_differ
FROM completed c
LEFT JOIN lines l ON l.order_id = c.id;

-- Duplicate order_items rows (every column identical)
SELECT COUNT(*) - (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM order_items) d) AS duplicate_item_rows
FROM order_items;

-- Order lines whose unit_price differs from the product list price
SELECT COUNT(*) AS lines_total,
       COUNT(*) FILTER (WHERE oi.unit_price <> p.price) AS lines_price_differs
FROM order_items oi
JOIN products p ON p.id = oi.product_id;
