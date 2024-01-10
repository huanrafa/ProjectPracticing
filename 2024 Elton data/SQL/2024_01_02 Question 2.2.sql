-- Q 2.2: Calculate article_per_sess_per_user
WITH session_article AS (
  SELECT
    user_id,
    session_id,
    COUNT(*) AS article_per_sess
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
  WHERE event_name = 'load_news_detail'
  GROUP BY session_id, user_id
),
-- NOTE 1: In some cases, a session_id contains 2 values of user_id: "3" (before logging in) and its unique user_id (after logging in).
--         The most precise articles/session value should be the SUM of those above, as "actual_article_per_sess"
-- actual_article AS (
--   SELECT
--     session_id,
--     SUM(article_per_sess) AS actual_article_per_sess
--   FROM session_article
--   GROUP BY session_id
-- ),

-- NOTE 2: It turns out that some session_id contain more than 2 values (e.g. e0870262-ea1d-461d-aa37-998f32ed6c19 contains user_id = 1, 3, 12, 13)
--         For simplifying, we will exclude "user_id=3" totally from calculation (i.e. use "article_per_sess" as articles/session value)
os_info AS (
  SELECT DISTINCT
    session_id,
    CASE WHEN JSON_VALUE(device, '$.os_name') = 'iOS' THEN 'iOS'
         ELSE 'Android' END AS os_name
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
)

SELECT
  user_id,
  SUM(article_per_sess) AS article_per_user,
  COUNT(s.session_id) AS number_of_session,
  ROUND(AVG(article_per_sess),2) AS article_per_sess_per_user
FROM session_article AS s
-- INNER JOIN actual_article AS a ON a.session_id = s.session_id
INNER JOIN os_info   AS o
ON o.session_id = s.session_id
WHERE user_id != 3 --Exclude those with user_id = 3
-- Exclude the following "AND"s for all users
  -- AND os_name = 'Android'
  -- AND os_name = 'iOS'
GROUP BY user_id
ORDER BY user_id;

-- From "2024-01-02 Question 2"
-- ==> avg_article_per_sess_all     = 2.29
--     avg_article_per_sess_Android = 2.38
--     avg_article_per_sess_iOS     = 2.23
-- NOTE: Those numbers are at the moment the code is written. They will change over time.