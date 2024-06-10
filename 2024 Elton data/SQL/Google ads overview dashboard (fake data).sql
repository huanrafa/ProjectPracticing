WITH dashboard AS (
  SELECT
    campaign_startDate AS date,
    account_id,
    campaign_name,
    campaign_id,

    metrics.clicks,
    metrics.impressions,
    metrics.conversions,
    metrics.interactions,
    metrics.costMicros/1000000 AS cost,
    ROUND(metrics.averageCpm/1000000, 2) AS averageCpm,
  FROM `xxx-data-warehouse.google_ad_manager_dwh.google_ad_xxx`
  ORDER BY campaign_startDate DESC, campaign_id
)

, name_clone AS (
  SELECT
      *,
      CONCAT('Campaign GG ', ROW_NUMBER() OVER (ORDER BY campaign_name)) AS campaign_name_clone,
      (1000+ROW_NUMBER() OVER (ORDER BY campaign_name)) AS campaign_id_clone,
  FROM
      (
        SELECT DISTINCT campaign_name
        FROM dashboard
      )
)

SELECT
  date AS campaign_startDate,
  -- account_id,
  campaign_name_clone AS campaign_name,
  campaign_id_clone AS campaign_id,

  STRUCT(
    clicks*2 AS clicks,
    impressions*3 AS impressions,
    CASE WHEN cost!=0 THEN CAST((conversions + FLOOR(RAND() * 101)) AS INT64)
         ELSE 0 END AS conversions,
    interactions*2 AS interactions,
    cost*5*1000000 AS costMicros,
    1000*(cost*5*1000000)/(impressions*3) AS averageCpm) AS metrics,
FROM dashboard
LEFT JOIN name_clone
USING (campaign_name)
ORDER BY date DESC
