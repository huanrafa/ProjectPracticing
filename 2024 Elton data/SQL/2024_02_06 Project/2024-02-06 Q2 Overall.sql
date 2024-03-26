WITH overall AS (
  SELECT -- *
    date_start,
    campaign_id,
    campaign_name,
    ma_kh,
    adset_id,
    MAX(clicks) AS clicks,
    MAX(reach) AS reach,
    MAX(impressions) AS impressions,
    MAX(spend) AS spend,
    MAX(social_spend) AS social_spend,
    MAX(outbound_clicks) AS outbound_clicks,
    MAX(link_clicks) AS link_clicks,
    MAX(post_engagements) AS post_engagements,
    MAX(page_engagaments) AS page_engagaments,
    MAX(post_reactions) AS post_reactions,
    MAX(post_comments) AS post_comments,
    MAX(onsite_conversion_messaging_conversation_started_7d) AS onsite_conversion_messaging_conversation_started_7d
  FROM `xxx.biv_facebook_ads_datamart.facebook_ads_insights_flatten`
  GROUP BY 1, 2, 3, 4, 5
  ORDER BY date_start DESC, adset_id
)

, email AS(
  SELECT
    mkh,
    login_email
  FROM `xxx.biv_lark_base_dwh.lark_base_mkh`
)

SELECT
  date_start,
  campaign_id,
  campaign_name,
  ma_kh,
  CASE WHEN login_email is NULL THEN 'huanrafa@gmail.com xxx@xxx.com yyy@yyy.com'
       ELSE CONCAT(login_email, ' huanrafa@gmail.com xxx@xxx.com yyy@yyy.com') END AS email,
  adset_id,
  clicks,
  reach,
  impressions,
  spend,
  social_spend,
  outbound_clicks,
  link_clicks,
  post_engagements,
  page_engagaments,
  post_reactions,
  post_comments,
  onsite_conversion_messaging_conversation_started_7d
FROM overall
LEFT JOIN email
ON overall.ma_kh = email.mkh
ORDER BY date_start DESC, adset_id