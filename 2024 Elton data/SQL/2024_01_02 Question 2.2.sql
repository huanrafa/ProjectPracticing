WITH session_article AS (
  SELECT
    user_id,
    session_id,
    COUNT(*) AS article_per_sess
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
  WHERE event_name = 'load_news_detail'
  GROUP BY session_id, user_id
  ORDER BY session_id
),
-- In some cases, a session_id contains 2 values of user_id: "3" (before logging in) and its unique user_id (after logging in).
-- The most precise articles/session value should be the SUM of those above, as "actual_article_per_sess"
actual_article AS (
  SELECT
    session_id,
    SUM(article_per_sess) AS actual_article_per_sess
  FROM session_article
  GROUP BY session_id
),
os_info AS (
  SELECT DISTINCT
    session_id,
    CASE WHEN JSON_VALUE(device, '$.os_name') = 'iOS' THEN 'iOS'
         ELSE 'Android' END AS os_name
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
)

SELECT
  user_id,
  SUM(actual_article_per_sess) AS article_per_user,
  COUNT(s.session_id) AS number_of_session,
  ROUND(AVG(actual_article_per_sess),2) AS article_per_sess_per_user
FROM session_article AS s
INNER JOIN actual_article AS a ON a.session_id = s.session_id
INNER JOIN os_info        AS o ON o.session_id = s.session_id
-- Exclude those with user_id = 3
WHERE user_id != 3
-- Exclude following "ANDs" for all users
  -- AND os_name = 'Android'
  -- AND os_name = 'iOS'
GROUP BY user_id
ORDER BY user_id;

-- From "2024-01-02 Question 2"
-- ==> avg_article_per_sess_all     = 2.29
--     avg_article_per_sess_Android = 2.38
--     avg_article_per_sess_iOS     = 2.23