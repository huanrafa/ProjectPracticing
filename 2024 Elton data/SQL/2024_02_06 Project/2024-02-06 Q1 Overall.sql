SELECT
  record_date AS date,
  page_id,
  page_name,
  page_impressions,
  page_post_engagements,
  page_engaged_users,
  page_consumptions,
  page_video_views,
  page_fans,
  page_fan_adds_unique,
  page_fan_removes_unique
FROM `biv-data-platform.biv_facebook_pages_datamart.facebook_pages_insights_flatten`
ORDER BY date DESC, page_name