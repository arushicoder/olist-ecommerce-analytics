
-- =========================================================
-- OLIST E-COMMERCE ANALYTICS
-- SQL BUSINESS ANALYSIS
-- Database: SQLite
-- =========================================================


-- QUERY 1: Monthly Revenue Analysis
-- Concepts: JOIN, SUM, GROUP BY, ORDER BY

SELECT
    strftime('%Y-%m', o.order_purchase_timestamp) AS order_month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders AS o
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY strftime('%Y-%m', o.order_purchase_timestamp)
ORDER BY order_month;


-- QUERY 2: Top 10 Product Categories by Revenue
-- Concepts: JOIN, LEFT JOIN, GROUP BY, ORDER BY, LIMIT

SELECT
    COALESCE(t.product_category_name_english,
             p.product_category_name) AS category,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items AS oi
JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
JOIN orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;


-- QUERY 3: Top 10 Brazilian States by Revenue
-- Concepts: Multiple JOINs, GROUP BY, ORDER BY

SELECT
    c.customer_state AS state,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;


-- QUERY 4: Average Delivery Days by State
-- Concepts: JOIN, AVG, julianday(), GROUP BY

SELECT
    c.customer_state AS state,
    ROUND(
        AVG(
            julianday(o.order_delivered_customer_date)
            - julianday(o.order_purchase_timestamp)
        ), 2
    ) AS average_delivery_days
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY average_delivery_days ASC;


-- QUERY 5: Revenue by Payment Type
-- Concepts: GROUP BY, SUM, COUNT, ORDER BY

SELECT
    payment_type,
    ROUND(SUM(payment_value), 2) AS total_payment,
    COUNT(*) AS total_transactions
FROM order_payments
GROUP BY payment_type
ORDER BY total_payment DESC;


-- QUERY 6: Top 10 Sellers by Revenue
-- Concepts: JOIN, GROUP BY, ORDER BY, LIMIT

SELECT
    s.seller_id,
    s.seller_state,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM sellers AS s
JOIN order_items AS oi
    ON s.seller_id = oi.seller_id
JOIN orders AS o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_id, s.seller_state
ORDER BY total_revenue DESC
LIMIT 10;


-- QUERY 7: On-Time vs Late Delivery Analysis
-- Concepts: CASE WHEN, COUNT, GROUP BY

SELECT
    CASE
        WHEN order_delivered_customer_date
             <= order_estimated_delivery_date
        THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS total_orders,
    ROUND(
        100.0 * COUNT(*) /
        (SELECT COUNT(*)
         FROM orders
         WHERE order_status = 'delivered'
           AND order_delivered_customer_date IS NOT NULL
           AND order_estimated_delivery_date IS NOT NULL),
        2
    ) AS percentage
FROM orders
WHERE order_status = 'delivered'
    AND order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_status
ORDER BY total_orders DESC;


-- QUERY 8: Average Customer Review by Product Category
-- Concepts: Multiple JOINs, AVG, GROUP BY

SELECT
    COALESCE(t.product_category_name_english,
             p.product_category_name) AS category,
    ROUND(AVG(r.review_score), 2) AS average_review_score,
    COUNT(DISTINCT r.review_id) AS total_reviews
FROM order_reviews AS r
JOIN order_items AS oi
    ON r.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY average_review_score DESC;


-- QUERY 9: States with Revenue Greater Than R$100,000
-- Concepts: CTE, HAVING, JOIN, GROUP BY

WITH state_revenue AS (
    SELECT
        c.customer_state AS state,
        SUM(oi.price) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id
    JOIN order_items AS oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
)

SELECT
    state,
    ROUND(total_revenue, 2) AS total_revenue,
    total_orders
FROM state_revenue
GROUP BY state
HAVING total_revenue > 100000
ORDER BY total_revenue DESC;
