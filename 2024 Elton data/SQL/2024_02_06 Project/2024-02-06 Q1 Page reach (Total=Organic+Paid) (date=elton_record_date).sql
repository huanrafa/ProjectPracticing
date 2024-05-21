WITH post AS (
  SELECT * FROM `biv-data-platform.biv_facebook_pages_01_dwh.facebook_page_posts_insights_detail_lifetime`
  UNION ALL
  SELECT * FROM `biv-data-platform.biv_facebook_pages_02_dwh.facebook_page_posts_insights_detail_lifetime`
  UNION ALL
  SELECT * FROM `biv-data-platform.biv_facebook_pages_03_dwh.facebook_page_posts_insights_detail_lifetime`
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
    post.elton_record_date AS date,
    DATE(post_created_time) AS created_date,
    post.name AS metric_name,
    CAST(value AS INTEGER) AS value,
    post.page_id,
    page.name AS page_name,
    SPLIT(post_id, '_')[offset(1)] AS post_id
  FROM post
  LEFT JOIN page
  ON page.id = post.page_id
  WHERE post.name in ('post_impressions_organic_unique', 'post_impressions_paid_unique') -- 'post_impressions_unique'
),

organic AS (
  SELECT
    date,
    created_date,
    page_name,
    page_id,
    value AS organic_reach,
    value - lag(value,1,0)
      OVER(PARTITION BY post_id ORDER BY date) AS organic_reach_change,
    post_id AS organic_post_id
  FROM source
  WHERE metric_name = 'post_impressions_organic_unique'
),
paid AS (
  SELECT
    date,
    created_date,
    page_name,
    page_id,
    value AS paid_reach,
    value - lag(value,1,0)
      OVER(PARTITION BY post_id ORDER BY date) AS paid_reach_change,
    post_id AS paid_post_id
  FROM source
  WHERE metric_name = 'post_impressions_paid_unique'  
),

reach_per_post AS (
  SELECT
    organic.date,
    organic.page_name,
    organic.page_id,
    organic_reach_change,
    paid_reach_change,
    organic_post_id AS post_id,
  FROM organic
  FULL JOIN paid
  ON organic.date = paid.date
    AND organic.page_id = paid.page_id
  WHERE organic_post_id = paid_post_id
)

SELECT
  date,
  page_name,
  SUM(organic_reach_change) AS total_organic_change,
  SUM(paid_reach_change) AS total_paid_change,
  (SUM(organic_reach_change) + SUM(paid_reach_change)) AS total_total_reach
FROM reach_per_post
GROUP BY date, page_name, page_id
ORDER BY date DESC
