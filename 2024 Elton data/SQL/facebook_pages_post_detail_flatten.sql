WITH source AS (
 SELECT
  CAST(post_created_time AS DATE) AS post_creation_date
    , page_id
    , page.name AS page_name
    , SPLIT(post_id, '_')[offset(1)] AS post_id
    , CONCAT('https://www.facebook.com/', page_id , '/' , 'posts/' , SPLIT(post_id, '_')[offset(1)] ,'/') AS post_shared_link
    , status_type
    , post_message
    , CAST(CASE WHEN post.name = 'post_impressions_unique' THEN value END AS INTEGER) AS post_reach
    , CAST(JSON_EXTRACT_SCALAR(value, '$.like') AS INTEGER) AS like_on_post
    , CAST(JSON_EXTRACT_SCALAR(value, '$.comment') AS INTEGER) AS comment_on_post
    , CAST(JSON_EXTRACT_SCALAR(value, '$.share') AS INTEGER) AS share_on_post

    , CASE WHEN post.name = 'post_clicks_by_type_unique' THEN CAST(JSON_EXTRACT_SCALAR(value, '$.other clicks') AS INTEGER) END AS post_order_click
    , CASE WHEN post.name = 'post_clicks_by_type_unique' THEN CAST(JSON_EXTRACT_SCALAR(value, '$.photo view') AS INTEGER) END AS post_photo_view
    , CASE WHEN post.name = 'post_clicks_by_type_unique' THEN CAST(JSON_EXTRACT_SCALAR(value, '$.link clicks') AS INTEGER) END AS post_link_click

    , CAST(CASE WHEN post.name = 'post_impressions_organic' THEN value END AS INTEGER) AS post_impressions_organic
    , CAST(CASE WHEN post.name = 'post_impressions_organic_unique' THEN value END AS INTEGER) AS post_impressions_organic_unique
    , CASE WHEN post.name = 'post_clicks_by_type' THEN CAST(JSON_EXTRACT_SCALAR(value, '$.other clicks') AS INTEGER) END AS post_click_type_other
    , CASE WHEN post.name = 'post_clicks_by_type' THEN CAST(JSON_EXTRACT_SCALAR(value, '$.photo view') AS INTEGER) END AS post_click_type_photo_view
    , CASE WHEN post.name = 'post_clicks_by_type' THEN CAST(JSON_EXTRACT_SCALAR(value, '$.link clicks') AS INTEGER) END AS post_click_type_link_click
    
    , post.elton_record_date
  FROM `xxx.xxx.facebook_page_posts_insights_detail_lifetime` AS post
  LEFT JOIN `xxx.xxx.facebook_page_pages_info` AS page
  ON page.id = post.page_id
  WHERE post.name in ('post_clicks_by_type_unique', 'post_activity_by_action_type_unique', 'post_impressions_unique', 'post_impressions_organic', 'post_impressions_organic_unique', 'post_clicks_by_type')
)

SELECT 
  post_creation_date
  , page_name
  , page_id
  , post_id
  , post_shared_link
  , post_message
  , COALESCE(MAX(post_reach),0) AS post_reach
  , COALESCE(MAX(like_on_post),0) AS like_on_post
  , COALESCE(MAX(comment_on_post),0) AS comment_on_post
  , COALESCE(MAX(share_on_post),0) AS share_on_post
  
  , COALESCE(MAX(post_order_click),0) AS post_order_click
  , COALESCE(MAX(post_link_click),0) AS post_link_click
  , COALESCE(MAX(post_photo_view),0) AS post_photo_view
  
  , COALESCE(MAX(post_impressions_organic),0) AS post_impressions_organic
  , COALESCE(MAX(post_impressions_organic_unique),0) AS post_impressions_organic_unique
  , COALESCE(MAX(post_click_type_other),0) AS post_click_type_other
  , COALESCE(MAX(post_click_type_photo_view),0) AS post_click_type_photo_view
  , COALESCE(MAX(post_click_type_link_click),0) AS post_click_type_link_click

  , elton_record_date
FROM source
GROUP BY post_creation_date, page_name, page_id , post_id , post_shared_link , post_message ,elton_record_date
ORDER BY post_creation_date DESC