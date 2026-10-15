-- E-Commerce Sales & Customer Analysis
-- File: 02_customer_analysis.sql
-- Purpose: Analyze completed-order customers and repeat purchasing.

USE ecommerce_analysis;

-- 1. Count unique customers with completed orders
SELECT
    COUNT(DISTINCT customer_id) AS unique_completed_customers
FROM orders
WHERE order_status = 'Completed';

-- 2. Count repeat customers
-- Repeat customer = at least two distinct completed orders
SELECT
    COUNT(*) AS repeat_customers
FROM (
    SELECT customer_id
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
    HAVING COUNT(DISTINCT order_id) >= 2
) AS repeat_customer_list;

-- 3. Calculate repeat customer rate
SELECT
    ROUND(
        100.0 * COUNT(CASE WHEN completed_orders >= 2 THEN 1 END)
        / NULLIF(COUNT(*), 0),
        2
    ) AS repeat_customer_rate_pct
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS completed_orders
    FROM orders
    WHERE order_status = 'Completed'
    GROUP BY customer_id
) AS customer_order_counts;

-- 4. Top 10 customers by completed revenue
SELECT
    c.customer_id,
    c.customer_name,
    ROUND(SUM(oi.quantity * p.price), 2) AS completed_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY completed_revenue DESC
LIMIT 10;
