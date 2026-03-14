-- ============================================================
-- MODULE 2: CUSTOMER BEHAVIOR & SEGMENTATION
-- Dataset: Shopee Thailand (2022-2025)
-- ============================================================


-- ------------------------------------------------------------
-- 2.1 Customer Order Summary (Base Table for Segmentation)
-- ------------------------------------------------------------
SELECT
    o.customer_id,
    c.province,
    c.gender,
    COUNT(o.order_id)                                           AS total_orders,
    ROUND(SUM(o.total_amount), 0)                               AS total_revenue,
    ROUND(AVG(o.total_amount), 0)                               AS avg_order_value,
    MIN(o.order_date)                                           AS first_order_date,
    MAX(o.order_date)                                           AS last_order_date,
    DATEDIFF(MAX(o.order_date), MIN(o.order_date))              AS customer_lifespan_days
FROM shopee_orders_thailand o
LEFT JOIN shopee_customers_thailand c USING (customer_id)
GROUP BY 1, 2, 3;


-- ------------------------------------------------------------
-- 2.2 Customer Segmentation (RFM-based)
-- ------------------------------------------------------------
WITH customer_stats AS (
    SELECT
        customer_id,
        COUNT(order_id)             AS frequency,
        ROUND(SUM(total_amount), 0) AS monetary,
        MAX(order_date)             AS last_order_date
    FROM shopee_orders_thailand
    GROUP BY 1
)
SELECT
    customer_id,
    frequency,
    monetary,
    last_order_date,
    CASE
        WHEN frequency = 1              THEN '1. One-Time'
        WHEN frequency BETWEEN 2 AND 5  THEN '2. Occasional'
        WHEN frequency BETWEEN 6 AND 10 THEN '3. Regular'
        ELSE                                 '4. Loyal'
    END                                                         AS segment
FROM customer_stats
ORDER BY monetary DESC;


-- ------------------------------------------------------------
-- 2.3 Revenue & Orders by Customer Segment
-- ------------------------------------------------------------
WITH customer_stats AS (
    SELECT
        customer_id,
        COUNT(order_id)             AS frequency,
        ROUND(SUM(total_amount), 0) AS monetary
    FROM shopee_orders_thailand
    GROUP BY 1
),
segmented AS (
    SELECT
        customer_id,
        monetary,
        CASE
            WHEN frequency = 1              THEN '1. One-Time'
            WHEN frequency BETWEEN 2 AND 5  THEN '2. Occasional'
            WHEN frequency BETWEEN 6 AND 10 THEN '3. Regular'
            ELSE                                 '4. Loyal'
        END AS segment
    FROM customer_stats
)
SELECT
    segment,
    COUNT(customer_id)                                          AS num_customers,
    ROUND(COUNT(customer_id) / SUM(COUNT(customer_id)) 
        OVER () * 100, 1)                                       AS customer_pct,
    ROUND(SUM(monetary), 0)                                     AS total_revenue,
    ROUND(SUM(monetary) / SUM(SUM(monetary)) 
        OVER () * 100, 1)                                       AS revenue_pct,
    ROUND(AVG(monetary), 0)                                     AS avg_revenue_per_customer
FROM segmented
GROUP BY 1
ORDER BY 1;


-- ------------------------------------------------------------
-- 2.4 New vs Returning Customers by Month
-- ------------------------------------------------------------
WITH first_order AS (
    SELECT
        customer_id,
        MIN(order_date)             AS first_order_date,
        LEFT(MIN(order_date), 7)    AS first_month
    FROM shopee_orders_thailand
    GROUP BY 1
)
SELECT
    o.year_month,
    COUNT(DISTINCT o.customer_id)                               AS total_customers,
    COUNT(DISTINCT CASE 
        WHEN fo.first_month = o.year_month 
        THEN o.customer_id END)                                 AS new_customers,
    COUNT(DISTINCT CASE 
        WHEN fo.first_month != o.year_month 
        THEN o.customer_id END)                                 AS returning_customers,
    ROUND(
        COUNT(DISTINCT CASE WHEN fo.first_month != o.year_month THEN o.customer_id END)
        / COUNT(DISTINCT o.customer_id) * 100
    , 1)                                                        AS returning_rate_pct
FROM shopee_orders_thailand o
LEFT JOIN first_order fo USING (customer_id)
GROUP BY 1
ORDER BY 1;


-- ------------------------------------------------------------
-- 2.5 Revenue by Province
-- ------------------------------------------------------------
SELECT
    c.province,
    COUNT(DISTINCT o.customer_id)                               AS unique_customers,
    COUNT(o.order_id)                                           AS total_orders,
    ROUND(SUM(o.total_amount), 0)                               AS total_revenue,
    ROUND(AVG(o.total_amount), 0)                               AS avg_order_value,
    ROUND(SUM(o.total_amount) / SUM(SUM(o.total_amount)) 
        OVER () * 100, 1)                                       AS revenue_share_pct
FROM shopee_orders_thailand o
LEFT JOIN shopee_customers_thailand c USING (customer_id)
GROUP BY 1
ORDER BY total_revenue DESC;
