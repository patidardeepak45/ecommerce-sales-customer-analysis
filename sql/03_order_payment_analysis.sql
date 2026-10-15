-- E-Commerce Sales & Customer Analysis
-- File: 03_order_payment_analysis.sql
-- Purpose: Analyze order status, completion rate, and payment methods.

USE ecommerce_analysis;

-- 1. Orders by status
SELECT
    order_status,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- 2. Overall order completion rate
SELECT
    COUNT(DISTINCT CASE
        WHEN order_status = 'Completed' THEN order_id
    END) AS completed_orders,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN order_status = 'Completed' THEN order_id
        END) / NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS completion_rate_pct
FROM orders;

-- 3. Orders by payment method
SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY payment_method
ORDER BY total_orders DESC;

-- 4. Completed revenue by payment method
SELECT
    o.payment_method,
    ROUND(SUM(oi.quantity * p.price), 2) AS completed_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'Completed'
GROUP BY o.payment_method
ORDER BY completed_revenue DESC;
