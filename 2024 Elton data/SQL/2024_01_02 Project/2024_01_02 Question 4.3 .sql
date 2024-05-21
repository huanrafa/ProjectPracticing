-- Q 4.3: How many times searching/trending function is used each day?

WITH date_search AS (
  SELECT
    DATE(TIMESTAMP_SECONDS(event_local_timestamp)) AS date,
    COUNT(*) AS search_per_day
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
  WHERE event_name = 'search_content'
  GROUP BY date
),
date_trend AS (
  SELECT
    DATE(TIMESTAMP_SECONDS(event_local_timestamp)) AS date,
    COUNT(*) AS trending_per_day
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
  WHERE event_name = 'trending_topic_click'
  GROUP BY date
),
original AS (
  SELECT DISTINCT
    DATE(TIMESTAMP_SECONDS(event_local_timestamp)) AS date,
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
  WHERE event_local_timestamp <= UNIX_SECONDS(CURRENT_TIMESTAMP())
)

SELECT
  O.date,
  CASE WHEN (search_per_day IS NULL) THEN 0
       ELSE search_per_day END AS search_per_day,
  CASE WHEN (trending_per_day IS NULL) THEN 0
       ELSE trending_per_day END AS trending_per_day
FROM original AS O
LEFT JOIN date_search AS S
ON O.date = S.date
LEFT JOIN date_trend AS T
ON S.date = T.date
ORDER BY O.date
