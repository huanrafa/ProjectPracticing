WITH comment_share_change AS (
  SELECT
    elton_record_date AS date,
    page_name, 
    page_id,
    comment_on_post AS comment,
    comment_on_post - lag(comment_on_post,1,0)
      OVER(PARTITION BY post_id ORDER BY elton_record_date) AS comment_change,
    share_on_post AS share,
    share_on_post - lag(share_on_post,1,0)
      OVER(PARTITION BY post_id ORDER BY elton_record_date) AS share_change,
    post_id
  FROM `biv-data-platform.biv_facebook_pages_datamart.vw_facebook_pages_post_detail_flatten`
  WHERE post_message IS NOT NULL
)

SELECT
  date, 
  page_name, 
  page_id,
  SUM(comment_change) AS comment,
  SUM(share_change) AS share
FROM comment_share_change
-- WHERE date BETWEEN '2024-01-24' AND '2024-02-20'
--   AND page_id = 159739753894830
GROUP BY date, page_name, page_id
ORDER BY date DESC
