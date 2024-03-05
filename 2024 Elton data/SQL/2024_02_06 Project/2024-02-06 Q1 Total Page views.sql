WITH overall AS (
  SELECT
    record_date,
    page_id,
    page_name,
  FROM `biv-data-platform.biv_facebook_pages_datamart.facebook_pages_insights_flatten`
),

page AS (
  SELECT * FROM `biv-data-platform.biv_facebook_pages_01_dwh.facebook_page_insights_daily`
  WHERE name = 'page_views_total'
  UNION DISTINCT
  SELECT * FROM `biv-data-platform.biv_facebook_pages_02_dwh.facebook_page_insights_daily`
  WHERE name = 'page_views_total'
)

SELECT 
  overall.record_date AS date,
  page_name,
  CAST(value AS INTEGER) AS page_views_total
FROM overall
LEFT JOIN page
ON overall.page_id = page.page_id
  AND overall.record_date = page.record_date
ORDER BY date DESC, page_name