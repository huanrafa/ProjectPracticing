SELECT
  post_creation_date AS date,
  page_name,
  post_message,
  post_id,
  MAX(post_reach) AS post_reach,
  (MAX(like_on_post) + MAX(comment_on_post) + MAX(share_on_post)) AS post_reaction
FROM `biv-data-platform.biv_facebook_pages_datamart.vw_facebook_pages_post_detail_flatten`
WHERE post_message IS NOT NULL
GROUP BY post_creation_date, page_name, post_message, post_id
ORDER BY post_creation_date DESC