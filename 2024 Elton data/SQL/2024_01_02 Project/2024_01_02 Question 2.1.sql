-- Q 2.1: Calculate article_per_sess_per_date
WITH session_article AS (
  SELECT
    DATE(TIMESTAMP_SECONDS(event_local_timestamp)) AS date,
    session_id,
    COUNT(*) AS article_per_sess
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
  WHERE event_name = 'load_news_detail'
  GROUP BY session_id, date
),
os_info AS (
  SELECT DISTINCT
    session_id,
    CASE WHEN JSON_VALUE(device, '$.os_name') = 'iOS' THEN 'iOS'
         ELSE 'Android' END AS os_name
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
)

-- SELECT
--   ROUND(AVG(article_per_sess),2) AS avg_article_per_sess
-- FROM session_article AS s
-- INNER JOIN os_info AS o
-- ON o.session_id = s.session_id
-- WHERE s.session_id IS NOT NULL
-- -- Exclude following "ANDs" for all users
--   -- AND os_name = 'Android'
--   -- AND os_name = 'iOS'


-- ==> avg_article_per_sess_all     = 2.29
--     avg_article_per_sess_Android = 2.38
--     avg_article_per_sess_iOS     = 2.23
-- NOTE: Those numbers are at the moment the code is written. They will change over time.


SELECT
  date,
  SUM(article_per_sess) AS article_per_date,
  COUNT(s.session_id) AS number_of_session,
  ROUND(AVG(article_per_sess),2) AS article_per_sess_per_date
FROM session_article AS s
INNER JOIN os_info AS o
ON o.session_id = s.session_id
WHERE s.session_id IS NOT NULL
-- Exclude the following "AND"s for avg_duration_all
  -- AND os_name = 'Android'
  -- AND os_name = 'iOS'
GROUP BY date
ORDER BY date;