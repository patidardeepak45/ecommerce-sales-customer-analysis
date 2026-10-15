-- E-Commerce Sales & Customer Analysis
-- File: 01_revenue_analysis.sql
-- Purpose: Analyze completed revenue by category and product.

USE ecommerce_analysis;

-- 1. Overall completed revenue
SELECT
    ROUND(SUM(oi.quantity * p.price), 2) AS completed_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed';

-- 2. Completed revenue by product category
SELECT
    p.category,
    ROUND(SUM(oi.quantity * p.price), 2) AS completed_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.category
ORDER BY completed_revenue DESC;

-- 3. Top 5 products by completed revenue
SELECT
    p.product_name,
    ROUND(SUM(oi.quantity * p.price), 2) AS completed_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY p.product_id, p.product_name
ORDER BY completed_revenue DESC
LIMIT 5;

-- Note: Revenue is calculated as quantity multiplied by product price.
