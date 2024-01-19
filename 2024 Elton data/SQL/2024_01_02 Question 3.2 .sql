-- Q 3.2: Calculate retention rate of Day 3/7/28
-- (i.e. Let's say a device started using app on Day 0. The question is, after Day 3/7/28, does he/she still use the app? Calculate percentage of devices still accessing the app)

WITH min_time_psuedo AS (
  SELECT
    user_psuedo_id,
    MIN(event_local_timestamp) AS psuedo_started,
    DATE(TIMESTAMP_SECONDS(MIN(event_local_timestamp))) AS psuedo_started_date
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
  WHERE session_id IS NOT NULL
  GROUP BY user_psuedo_id
),
min_time_session AS (
  SELECT
    user_psuedo_id,
    session_id,
    MIN(event_local_timestamp) AS session_started,
    DATE(TIMESTAMP_SECONDS(MIN(event_local_timestamp))) AS session_started_date
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
  WHERE user_psuedo_id IS NOT NULL
   OR session_id IS NOT NULL
  GROUP BY user_psuedo_id, session_id
),
session_flagged AS (
  SELECT
    user_psuedo_id,
    session_id,
    (session_started - psuedo_started) AS period,
    psuedo_started_date,
    session_started_date,
    CASE  WHEN ((session_started - psuedo_started) >= 1) THEN 1
          ELSE 0 END AS retent_1s,
    CASE  WHEN ((session_started - psuedo_started) >= 86400*3) THEN 1
          ELSE 0 END AS retent_3_day,
    CASE  WHEN ((session_started - psuedo_started) >= 86400*7) THEN 1
          ELSE 0 END AS retent_7_day,
    CASE  WHEN ((session_started - psuedo_started) >= 86400*28) THEN 1
          ELSE 0 END AS retent_28_day
  FROM min_time_session AS S
  INNER JOIN min_time_psuedo AS P
  USING(user_psuedo_id)
),
psuedo_flagged AS (
  SELECT
    user_psuedo_id,
    COUNT(session_id) AS number_session,
    MAX(retent_1s) AS retent_1s,
    MAX(retent_3_day) AS retent_3_day,
    MAX(retent_7_day) AS retent_7_day,
    MAX(retent_28_day) AS retent_28_day
  FROM session_flagged
  -- WHERE psuedo_started_date BETWEEN DATE('2023-12-01') AND DATE('2023-12-31') --Remove this to cover all dates
  GROUP BY user_psuedo_id
)

--Main
SELECT
  ROUND(AVG(retent_3_day)*100, 2) AS retent_3,
  ROUND(AVG(retent_7_day)*100, 2) AS retent_7,
  ROUND(AVG(retent_28_day)*100, 2) AS retent_28
FROM psuedo_flagged
-- To check the retention rate of those who at least came back to use the app once, use:
-- WHERE retent_1s != 0
