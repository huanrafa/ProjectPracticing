WITH insight AS (
  SELECT * FROM `biv-data-platform.biv_facebook_pages_01_dwh.facebook_page_insights_daily`
  UNION ALL
  SELECT * FROM `biv-data-platform.biv_facebook_pages_02_dwh.facebook_page_insights_daily`
),
page AS (
  SELECT * FROM `biv-data-platform.biv_facebook_pages_01_dwh.facebook_page_pages_info`
  UNION DISTINCT
  SELECT * FROM `biv-data-platform.biv_facebook_pages_02_dwh.facebook_page_pages_info`
  UNION DISTINCT
  SELECT * FROM `biv-data-platform.biv_facebook_pages_03_dwh.facebook_page_pages_info`
),
source AS (
  SELECT
    insight.record_date AS date,
    insight.page_id,
    page.name AS page_name,
    insight.name AS metrics,
    insight.value AS value
  FROM insight
  LEFT JOIN page
  ON page.id = insight.page_id
  WHERE insight.name in ('page_impressions_organic_unique_v2', 'page_impressions_paid_unique')
                        -- 'page_impressions', 'page_impressions_unique','page_impressions_nonviral_unique', 'page_impressions_viral_unique')
)

, organic AS (
  SELECT
    date,
    page_id,
    page_name,
    value AS organic_reach,
  FROM source
  WHERE metrics = 'page_impressions_organic_unique_v2'
)
, paid AS (
  SELECT
    date,
    page_id,
    page_name,
    value AS paid_reach,
  FROM source
  WHERE metrics = 'page_impressions_paid_unique'
)

SELECT
  organic.date AS date,
  organic.page_id AS page_id,
  organic.page_name AS page_name,
  CAST(organic_reach AS INTEGER) AS organic_reach,
  CAST(paid_reach AS INTEGER) AS paid_reach,
  (CAST(organic_reach AS INTEGER) + CAST(paid_reach AS INTEGER)) AS total_reach,
FROM organic
LEFT JOIN paid
ON organic.date = paid.date
  AND organic.page_id = paid.page_id
ORDER BY organic.date DESC
