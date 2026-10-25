-- 02_data_quality.sql
-- Checks the data problems that the business queries have to handle.

-- 1. Raw status values: the same status is spelled in different ways
SELECT status, COUNT(*) AS orders
FROM orders
GROUP BY status
ORDER BY orders DESC;

-- 2. Exact duplicate order rows (every column identical)
SELECT COUNT(*) - (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM orders) d) AS duplicate_rows
FROM orders;

-- 3. How much revenue the duplicates add (completed orders)
SELECT
    (SELECT SUM(total_amount) FROM orders
      WHERE LOWER(TRIM(status)) = 'completed')                      AS revenue_with_dupes,
    (SELECT SUM(total_amount) FROM (SELECT DISTINCT * FROM orders) d
      WHERE LOWER(TRIM(status)) = 'completed')                      AS revenue_without_dupes;

-- 4. Orders without an amount (after removing duplicates)
SELECT LOWER(TRIM(status)) AS status_clean,
       COUNT(*) AS orders_without_amount
FROM (SELECT DISTINCT * FROM orders) d
WHERE total_amount IS NULL
GROUP BY 1
ORDER BY 2 DESC;

-- 5. Customers without a country
SELECT COUNT(*) AS customers_without_country
FROM customers
WHERE country IS NULL OR TRIM(country) = '';

-- 6. Raw segment values
SELECT segment, COUNT(*) AS customers
FROM customers
GROUP BY segment
ORDER BY customers DESC;

-- 7. Orders whose customer_id does not exist in customers
SELECT COUNT(*) AS orphan_orders
FROM orders o
WHERE NOT EXISTS (SELECT 1 FROM customers c WHERE c.id = o.customer_id);

-- 8. Duplicate customer ids
SELECT COUNT(*) - COUNT(DISTINCT id) AS duplicate_customer_ids
FROM customers;

-- 9. Date range of the orders
SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order
FROM orders;
