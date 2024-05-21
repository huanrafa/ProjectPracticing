-- Q 3: Calculate the rate of coming back within 3, 7, 28 days (of all devices)

-- NOTE 1: "Coming back" moment is marked as the start of the 2nd session (per user_psuedo_id)
-- (i.e. period of time being used for comparison is differ_bw_2_first_session = MIN(S.session_started - P.psuedo_started))

-- NOTE 2: Devices that came back within the first 3 days means that they have been certainly back within the first 7 days and 28 days
-- (i.e. If Back_3_day = 1, then Back_7_day = 1 and Back_28_day = 1, obviously)
-- (i.e. percent_back_3 <= percent_back_7 <= percent_back_28)

WITH min_time_psuedo AS (
  SELECT
    user_psuedo_id,
    MIN(event_local_timestamp) AS psuedo_started
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
  GROUP BY user_psuedo_id
),
min_time_session AS (
  SELECT
    user_psuedo_id,
    session_id,
    MIN(event_local_timestamp) AS session_started
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
  WHERE user_psuedo_id IS NOT NULL
  GROUP BY user_psuedo_id, session_id
),
interval_flagged AS (
  SELECT
    S.user_psuedo_id,
    MIN(S.session_started - P.psuedo_started) AS differ_bw_2_first_session,
    CASE  WHEN (MIN(S.session_started - P.psuedo_started) <= 86400*3 ) THEN 1
          ELSE 0 END AS Back_3_day,
    CASE  WHEN (MIN(S.session_started - P.psuedo_started) <= 86400*7 ) THEN 1
          ELSE 0 END AS Back_7_day,
    CASE  WHEN (MIN(S.session_started - P.psuedo_started) <= 86400*28) THEN 1
          ELSE 0 END AS Back_28_day
  FROM min_time_session AS S
  INNER JOIN min_time_psuedo AS P
  ON S.user_psuedo_id = P.user_psuedo_id
  WHERE S.session_started != P.psuedo_started -- Exclude the first session (and those started at the same time as the first session)
  GROUP BY S.user_psuedo_id
)

--Main
SELECT
  ROUND(AVG(Back_3_day)*100, 2) AS percent_back_3,
  ROUND(AVG(Back_7_day)*100, 2) AS percent_back_7,
  ROUND(AVG(Back_28_day)*100, 2) AS percent_back_28
FROM interval_flagged
