-- ============================================================
-- MODULE 4: LOGISTICS & DELIVERY PERFORMANCE
-- Dataset: Shopee Thailand (2022-2025)
-- ============================================================


-- ------------------------------------------------------------
-- 4.1 Overall Delivery Performance Summary
-- ------------------------------------------------------------
SELECT
    COUNT(order_item_id)                                        AS total_shipments,
    ROUND(AVG(actual_delivery_days), 1)                         AS avg_delivery_days,
    MIN(actual_delivery_days)                                   AS min_delivery_days,
    MAX(actual_delivery_days)                                   AS max_delivery_days,
    SUM(CASE WHEN actual_delivery_days <= 3 THEN 1 ELSE 0 END)  AS delivered_in_3days,
    SUM(CASE WHEN actual_delivery_days <= 5 THEN 1 ELSE 0 END)  AS delivered_in_5days,
    ROUND(SUM(CASE WHEN actual_delivery_days <= 5 THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 1)                                    AS on_time_rate_pct
FROM shopee_shipments_thailand;


-- ------------------------------------------------------------
-- 4.2 Delivery Performance by Courier
-- ------------------------------------------------------------
SELECT
    courier_name,
    COUNT(order_item_id)                                        AS total_shipments,
    ROUND(COUNT(order_item_id) / SUM(COUNT(order_item_id))
        OVER () * 100, 1)                                       AS market_share_pct,
    ROUND(AVG(actual_delivery_days), 1)                         AS avg_delivery_days,
    SUM(CASE WHEN actual_delivery_days <= 5 THEN 1 ELSE 0 END)  AS on_time_deliveries,
    ROUND(SUM(CASE WHEN actual_delivery_days <= 5 THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 1)                                    AS on_time_rate_pct
FROM shopee_shipments_thailand
GROUP BY 1
ORDER BY total_shipments DESC;


-- ------------------------------------------------------------
-- 4.3 Delivery Status Distribution
-- ------------------------------------------------------------
SELECT
    delivery_status,
    COUNT(order_item_id)                                        AS total_shipments,
    ROUND(COUNT(order_item_id) / SUM(COUNT(order_item_id))
        OVER () * 100, 1)                                       AS share_pct,
    ROUND(AVG(actual_delivery_days), 1)                         AS avg_delivery_days
FROM shopee_shipments_thailand
GROUP BY 1
ORDER BY total_shipments DESC;


-- ------------------------------------------------------------
-- 4.4 Monthly Delivery Performance Trend
-- ------------------------------------------------------------
SELECT
    LEFT(delivery_date, 7)                                      AS year_month,
    COUNT(order_item_id)                                        AS total_shipments,
    ROUND(AVG(actual_delivery_days), 1)                         AS avg_delivery_days,
    ROUND(SUM(CASE WHEN actual_delivery_days <= 5 THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 1)                                    AS on_time_rate_pct
FROM shopee_shipments_thailand
WHERE delivery_date IS NOT NULL
GROUP BY 1
ORDER BY 1;


-- ------------------------------------------------------------
-- 4.5 Delivery Days Bucket Distribution
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN actual_delivery_days <= 1  THEN '1. Same/Next Day'
        WHEN actual_delivery_days <= 3  THEN '2. 2-3 Days'
        WHEN actual_delivery_days <= 5  THEN '3. 4-5 Days'
        WHEN actual_delivery_days <= 7  THEN '4. 6-7 Days'
        ELSE                                 '5. 8+ Days'
    END                                                         AS delivery_speed,
    COUNT(order_item_id)                                        AS total_shipments,
    ROUND(COUNT(order_item_id) / SUM(COUNT(order_item_id))
        OVER () * 100, 1)                                       AS share_pct
FROM shopee_shipments_thailand
GROUP BY 1
ORDER BY 1;
