-- ============================================================
-- MODULE 1: SALES PERFORMANCE & REVENUE TREND
-- Dataset: Shopee Thailand (2022-2025)
-- ============================================================


-- ------------------------------------------------------------
-- 1.1 Yearly Revenue Summary (YoY Growth)
-- ------------------------------------------------------------
SELECT
    LEFT(order_date, 4)                                         AS year,
    COUNT(order_id)                                             AS total_orders,
    COUNT(DISTINCT customer_id)                                 AS unique_customers,
    ROUND(SUM(total_amount), 0)                                 AS total_revenue,
    ROUND(AVG(total_amount), 0)                                 AS avg_order_value,
    ROUND(SUM(total_amount) - LAG(SUM(total_amount)) 
        OVER (ORDER BY LEFT(order_date, 4)), 0)                 AS revenue_diff,
    ROUND(
        (SUM(total_amount) - LAG(SUM(total_amount)) 
            OVER (ORDER BY LEFT(order_date, 4)))
        / LAG(SUM(total_amount)) OVER (ORDER BY LEFT(order_date, 4)) * 100
    , 1)                                                        AS yoy_growth_pct
FROM shopee_orders_thailand
GROUP BY 1
ORDER BY 1;


-- ------------------------------------------------------------
-- 1.2 Monthly Revenue Trend (Seasonality)
-- ------------------------------------------------------------
SELECT
    year_month,
    COUNT(order_id)                                             AS total_orders,
    ROUND(SUM(total_amount), 0)                                 AS total_revenue,
    ROUND(AVG(total_amount), 0)                                 AS avg_order_value,
    ROUND(SUM(shipping_fee_total), 0)                           AS total_shipping_fee,
    ROUND(SUM(commission_total), 0)                             AS total_commission
FROM shopee_orders_thailand
GROUP BY 1
ORDER BY 1;


-- ------------------------------------------------------------
-- 1.3 Revenue by Day of Week
-- ------------------------------------------------------------
SELECT
    DAYNAME(order_date)                                         AS day_of_week,
    DAYOFWEEK(order_date)                                       AS day_number,
    COUNT(order_id)                                             AS total_orders,
    ROUND(SUM(total_amount), 0)                                 AS total_revenue,
    ROUND(AVG(total_amount), 0)                                 AS avg_order_value
FROM shopee_orders_thailand
GROUP BY 1, 2
ORDER BY 2;


-- ------------------------------------------------------------
-- 1.4 Quarterly Revenue Summary
-- ------------------------------------------------------------
SELECT
    LEFT(order_date, 4)                                         AS year,
    QUARTER(order_date)                                         AS quarter,
    CONCAT(LEFT(order_date, 4), ' Q', QUARTER(order_date))     AS year_quarter,
    COUNT(order_id)                                             AS total_orders,
    ROUND(SUM(total_amount), 0)                                 AS total_revenue,
    ROUND(AVG(total_amount), 0)                                 AS avg_order_value
FROM shopee_orders_thailand
GROUP BY 1, 2, 3
ORDER BY 1, 2;


-- ------------------------------------------------------------
-- 1.5 Revenue Breakdown (Subtotal / Shipping / Commission)
-- ------------------------------------------------------------
SELECT
    LEFT(order_date, 4)                                         AS year,
    ROUND(SUM(subtotal_amount), 0)                              AS subtotal_revenue,
    ROUND(SUM(shipping_fee_total), 0)                           AS total_shipping,
    ROUND(SUM(commission_total), 0)                             AS total_commission,
    ROUND(SUM(maintenance_total), 0)                            AS total_maintenance,
    ROUND(SUM(total_amount), 0)                                 AS total_revenue,
    ROUND(SUM(shipping_fee_total) / SUM(total_amount) * 100, 1) AS shipping_pct,
    ROUND(SUM(commission_total) / SUM(total_amount) * 100, 1)  AS commission_pct
FROM shopee_orders_thailand
GROUP BY 1
ORDER BY 1;
