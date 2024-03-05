SELECT
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
FROM `biv-data-platform.biv_facebook_ads_datamart.facebook_ads_insights_flatten`
GROUP BY 1, 2, 3, 4, 5
ORDER BY date_start DESC, adset_id