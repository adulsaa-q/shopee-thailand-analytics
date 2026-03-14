-- ============================================================
-- MODULE 3: CAMPAIGN EFFECTIVENESS & DISCOUNT ANALYSIS
-- Dataset: Shopee Thailand (2022-2025)
-- ============================================================


-- ------------------------------------------------------------
-- 3.1 Campaign Revenue Summary
-- ------------------------------------------------------------
SELECT
    c.campaign_id,
    c.campaign_name,
    c.campaign_type,
    c.start_date,
    c.end_date,
    COUNT(o.order_id)                                           AS total_orders,
    COUNT(DISTINCT o.customer_id)                               AS unique_customers,
    ROUND(SUM(o.total_amount), 0)                               AS total_revenue,
    ROUND(AVG(o.total_amount), 0)                               AS avg_order_value
FROM shopee_campaigns_thailand c
LEFT JOIN shopee_orders_thailand o USING (campaign_id)
GROUP BY 1, 2, 3, 4, 5
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- 3.2 Campaign vs Non-Campaign Performance
-- ------------------------------------------------------------
SELECT
    CASE 
        WHEN campaign_id IS NOT NULL THEN 'Campaign'
        ELSE 'Non-Campaign'
    END                                                         AS order_type,
    COUNT(order_id)                                             AS total_orders,
    ROUND(COUNT(order_id) / SUM(COUNT(order_id)) 
        OVER () * 100, 1)                                       AS order_share_pct,
    ROUND(SUM(total_amount), 0)                                 AS total_revenue,
    ROUND(SUM(total_amount) / SUM(SUM(total_amount)) 
        OVER () * 100, 1)                                       AS revenue_share_pct,
    ROUND(AVG(total_amount), 0)                                 AS avg_order_value
FROM shopee_orders_thailand
GROUP BY 1;


-- ------------------------------------------------------------
-- 3.3 Campaign AOV Lift vs Non-Campaign
-- ------------------------------------------------------------
WITH campaign_aov AS (
    SELECT ROUND(AVG(total_amount), 0) AS campaign_aov
    FROM shopee_orders_thailand
    WHERE campaign_id IS NOT NULL
),
non_campaign_aov AS (
    SELECT ROUND(AVG(total_amount), 0) AS non_campaign_aov
    FROM shopee_orders_thailand
    WHERE campaign_id IS NULL
)
SELECT
    campaign_aov,
    non_campaign_aov,
    campaign_aov - non_campaign_aov                             AS aov_diff,
    ROUND((campaign_aov - non_campaign_aov) 
        / non_campaign_aov * 100, 1)                            AS aov_lift_pct
FROM campaign_aov, non_campaign_aov;


-- ------------------------------------------------------------
-- 3.4 Revenue by Campaign Type
-- ------------------------------------------------------------
SELECT
    c.campaign_type,
    COUNT(DISTINCT c.campaign_id)                               AS num_campaigns,
    COUNT(o.order_id)                                           AS total_orders,
    ROUND(SUM(o.total_amount), 0)                               AS total_revenue,
    ROUND(AVG(o.total_amount), 0)                               AS avg_order_value
FROM shopee_campaigns_thailand c
LEFT JOIN shopee_orders_thailand o USING (campaign_id)
GROUP BY 1
ORDER BY total_revenue DESC;


-- ------------------------------------------------------------
-- 3.5 Discount Bucket Analysis
-- ------------------------------------------------------------
SELECT
    CASE
        WHEN discount_percent = 0           THEN '0. No Discount'
        WHEN discount_percent <= 10         THEN '1. Low (1-10%)'
        WHEN discount_percent <= 20         THEN '2. Mid (11-20%)'
        ELSE                                     '3. High (21-25%)'
    END                                                         AS discount_bucket,
    COUNT(product_campaign_id)                                  AS num_products,
    ROUND(AVG(discount_percent), 1)                             AS avg_discount_pct,
    ROUND(MIN(discount_percent), 1)                             AS min_discount,
    ROUND(MAX(discount_percent), 1)                             AS max_discount
FROM shopee_product_campaign_thailand
GROUP BY 1
ORDER BY 1;


-- ------------------------------------------------------------
-- 3.6 Top 10 Campaigns by Revenue
-- ------------------------------------------------------------
SELECT
    c.campaign_name,
    c.campaign_type,
    COUNT(o.order_id)                                           AS total_orders,
    COUNT(DISTINCT o.customer_id)                               AS unique_customers,
    ROUND(SUM(o.total_amount), 0)                               AS total_revenue,
    ROUND(AVG(o.total_amount), 0)                               AS avg_order_value
FROM shopee_campaigns_thailand c
INNER JOIN shopee_orders_thailand o USING (campaign_id)
GROUP BY 1, 2
ORDER BY total_revenue DESC
LIMIT 10;
