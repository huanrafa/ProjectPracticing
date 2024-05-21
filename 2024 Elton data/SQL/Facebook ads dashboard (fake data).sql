WITH dashboard AS (
  SELECT
    date_start,
    campaign_id,
    campaign_name,
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
  FROM `xxx.xxx_facebook_ads_datamart.facebook_ads_insights_flatten`
  GROUP BY 1, 2, 3, 4
  ORDER BY date_start DESC, adset_id
)

, name_clone AS (
  SELECT
      *,
      CONCAT('Campaign ', ROW_NUMBER() OVER (ORDER BY campaign_name)) AS campaign_name_clone,
  FROM
      (
        SELECT DISTINCT campaign_name
        FROM dashboard
      )
)

SELECT
  date_start,
  campaign_name_clone AS campaign_name,
  clicks*3 AS clicks,
  reach*2 AS reach,
  impressions*3 AS impressions,
  spend*2 AS spend,
  social_spend*2 AS social_spend,
  outbound_clicks*5 AS outbound_clicks,
  link_clicks*10 AS link_clicks,
  post_engagements*2 AS post_engagements,
  page_engagaments*2 AS page_engagaments,
  post_reactions*4 AS post_reactions,
  post_comments*3 AS post_comments,
  onsite_conversion_messaging_conversation_started_7d*3 AS onsite_conversion_messaging_conversation_started_7d
FROM dashboard
LEFT JOIN name_clone
USING (campaign_name)
WHERE date_start < '2024-04-07'
ORDER BY date_start DESC, adset_id


