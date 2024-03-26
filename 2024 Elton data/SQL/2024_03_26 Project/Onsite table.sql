WITH shopee_onsite AS (
  SELECT
    "shopee" AS platform_name,
    DATE(PARSE_DATETIME('%d/%m/%Y %H:%M', start_date)) AS date,
    CASE WHEN product_id = "None" THEN NULL
         ELSE SUBSTR(product_id, 1, LENGTH(product_id) - 2) END AS product_id,
    -- short_sku,
    expense,
    gmv AS revenue,
    direct_gmv AS direct_revenue,
    conversions AS orders,
    direct_conversions AS direct_orders,
    items_sold AS units_sold,
    direct_items_sold AS direct_units_sold,
    impression,
    clicks,
    ctr
  FROM `xxx.google_drive_dwh.google_drive_shopee_onsite_ads`
)
, lazada_onsite AS (
  SELECT
    "lazada" AS platform_name,
    CAST(date AS DATE) AS date,
    CAST(product_id_the_id_of_this_product_in_product_management AS STRING) AS product_id,
    -- short_sku,
    spend AS expense,
    revenue,
    direct_revenue,
    orders,
    direct_orders,
    units_sold,
    direct_units_sold,
    impression,
    clicks,
    ctr
  FROM `xxx.google_drive_dwh.google_drive_lazada_onsite_ads`
)

, union_onsite AS (
  SELECT * FROM shopee_onsite
  UNION ALL
  SELECT * FROM lazada_onsite
)

SELECT * FROM union_onsite

