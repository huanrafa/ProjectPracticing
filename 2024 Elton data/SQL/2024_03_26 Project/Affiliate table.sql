WITH tiktok_aff AS (
  SELECT
    "tiktok" AS platform_name,
    CAST(order_id AS STRING) AS order_id,
    CAST(product_id AS STRING) AS product_id,
    -- short_sku,
    CASE WHEN actual_commission_base = "None" THEN NULL
         ELSE CAST(actual_commission_base AS FLOAT64) END AS revenue,
    quantity AS orders,
    quantity AS units_sold,
    CASE WHEN actual_commission_payment = "None" THEN NULL
         ELSE CAST(actual_commission_payment AS FLOAT64) END AS expense,
    CAST(commission_rate AS FLOAT64) AS commission_rate,
    order_status,
    creator_username,
    content_type
  FROM `xxx.google_drive_dwh.google_drive_tiktok_affiliate`
)
-- , shopee_aff AS (
--   SELECT
--     "shopee" AS platform_name,
--     CAST(order_id AS STRING) AS order_id,
--     CAST(item_id AS STRING) AS product_id,
--     -- short_sku,
--     CAST(purchase_value AS FLOAT64) AS revenue,
--     qty AS orders,
--     qty AS units_sold,
--     CAST(expense AS FLOAT64) AS expense,
--     CAST(SUBSTR(commi_rate, 1, LENGTH(commi_rate) - 1) AS FLOAT64) AS commission_rate,
--     order_status,
--     affiliate_username AS creator_username,
--     channel AS content_type
--   FROM `xxx.google_drive_dwh.google_drive_shopee_affiliate`
-- )
, lazada_aff AS (
  SELECT
    "lazada" AS platform_name,
    CAST(NULL AS STRING) AS order_id,
    CAST(item_id AS STRING) AS product_id,
    -- short_sku,
    revenue,
    orders,
    units_sold,
    est__spend AS expense,
    CAST(NULL AS FLOAT64) AS commission_rate,
    CAST(NULL AS STRING) AS order_status,
    CAST(NULL AS STRING) AS creator_username,
    CAST(NULL AS STRING) AS content_type
  FROM `xxx.google_drive_dwh.google_drive_lazada_affiliate`
)


, union_aff AS (
  SELECT * FROM tiktok_aff
  UNION ALL
  SELECT * FROM lazada_aff
  -- UNION ALL
  -- SELECT * FROM shopee_aff
)

SELECT * FROM union_aff

