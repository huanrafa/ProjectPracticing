-- In 'android' and 'iOS', can set constraint as "WHERE device LIKE '%iOS%'" OR "WHERE REGEXP_EXTRACT(device, r'"os_name":\s*"(.*?)"') = 'iOS'"
-- "GROUP BY session_id, date, device" is wrong, as in some cases, 1 session_id does not mean 1 device (e.g. 333be249-c152-4389-b0ac-9e78128b03b7)
WITH session_info AS (
  SELECT  
    DATE(TIMESTAMP_SECONDS(event_local_timestamp)) AS date,
    MAX(event_local_timestamp) - MIN(event_local_timestamp) AS session_duration,
    session_id,
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
  GROUP BY session_id, date
),
os_info AS (
  SELECT DISTINCT
    session_id,
    CASE WHEN JSON_VALUE(device, '$.os_name') = 'iOS' THEN 'iOS'
         ELSE 'Android' END AS os_name
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
)

-- Main
SELECT  
  date,
  ROUND(AVG(session_duration), 2) AS avg_duration
FROM session_info AS s
INNER JOIN  os_info AS o
ON o.session_id = s.session_id
WHERE s.session_id IS NOT NULL
  AND session_duration != 0
-- Exclude following "ANDs" for avg_duration_all
  -- AND os_name = 'Android'
  -- AND os_name = 'iOS'
GROUP BY date
ORDER BY date;

-- The above code expresses 1 type of avg_duration at a time, if we want to see all of them side-by-side, use the following:
-- IMPORTANT NOTE: If we ever want to create multiple CTEs with similar purposes (e.g. session_duration) like the following code, in all CTEs, they MUST be calculated exactly the same way
-- (e.g. GROUP BY session_id, date) and then in Main code, JOIN them exactly with those variables (e.g. ON (s.session_id = a.session_id) AND (s.date = a.date))
-- WITH session_info AS (
--   SELECT 
--     DATE(TIMESTAMP_SECONDS(event_local_timestamp)) AS date,
--     MAX(event_local_timestamp) - MIN(event_local_timestamp) AS session_duration,
--     session_id       
--   FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
--   GROUP BY session_id, date
-- ),
-- android AS (
--   SELECT
--     DATE(TIMESTAMP_SECONDS(event_local_timestamp)) AS date,
--     MAX(event_local_timestamp) - MIN(event_local_timestamp) AS session_duration,
--     session_id       
--   FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
--   WHERE JSON_VALUE(device, '$.os_name') != 'iOS'
--   GROUP BY session_id, date
-- ),
-- iOS AS (
--   SELECT
--     DATE(TIMESTAMP_SECONDS(event_local_timestamp)) AS date,
--     MAX(event_local_timestamp) - MIN(event_local_timestamp) AS session_duration,
--     session_id       
--   FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
--   WHERE JSON_VALUE(device, '$.os_name') = 'iOS'
--   GROUP BY session_id, date
-- )

-- -- Main
-- SELECT  
--   s.date,
--   ROUND(AVG(s.session_duration), 2) AS avg_duration_all,
--   ROUND(AVG(a.session_duration), 2) AS avg_duration_android,
--   ROUND(AVG(i.session_duration), 2) AS avg_duration_iOS
-- FROM session_info AS s
-- LEFT JOIN android AS a ON (s.session_id = a.session_id) AND (s.date = a.date)
-- LEFT JOIN iOS     AS i ON (s.session_id = i.session_id) AND (s.date = i.date)
-- WHERE s.session_id IS NOT NULL
-- GROUP BY date
-- ORDER BY date;
