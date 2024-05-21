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
    DATE(post_created_time) AS date,
    post.name AS metric_name,
    CAST(value AS INTEGER) AS value,
    post.page_id,
    page.name AS page_name,
    post.post_id
  FROM post
  LEFT JOIN page
  ON page.id = post.page_id
  WHERE post.name in ('post_impressions_unique', 'post_impressions_organic_unique', 'post_impressions_paid_unique')
),

organic AS (
  SELECT
    date,
    page_name,
    value AS organic_reach,
    post_id AS organic_post_id
  FROM source
  WHERE metric_name = 'post_impressions_organic_unique' 
),
paid AS (
  SELECT
    date,
    page_name,
    value AS paid_reach,
    post_id AS paid_post_id
  FROM source
  WHERE metric_name = 'post_impressions_paid_unique'  
),

reach_per_post AS (
  SELECT
    organic.date,
    organic.page_name,
    MAX(organic_reach) AS organic_reach,
    organic_post_id,
    MAX(paid_reach) AS paid_reach,
    paid_post_id,
  FROM organic
  FULL JOIN paid
  ON organic.date = paid.date
    AND organic.page_name = paid.page_name
  WHERE organic_post_id = paid_post_id
  GROUP BY organic.date, organic.page_name, organic_post_id, paid_post_id
)

SELECT
  date,
  page_name,
  SUM(organic_reach) AS total_organic_reach,
  SUM(paid_reach) AS total_paid_reach,
  (SUM(organic_reach) + SUM(paid_reach)) AS total_total_reach
FROM reach_per_post
GROUP BY date, page_name
ORDER BY date DESC

