-- Q 4.1: On average,  how many times searching/trending function is used each session?
-- Q 4.2: Per user_id, how many times searching/trending function is used each session?

-- Total number of sessions:                                 232974
-- Number of sessions with 'load_article_search_listing':       419
-- Number of sessions with 'search_content':                    144
-- Number of sessions with 'navigation_search_button_click':    192
-- Number of sessions with 'trending_topic_click':              292
-- NOTE: Those numbers are at the moment the code is written. They will change over time.

-- As 'load_article_search_listing' can be the results of different actions, such as: 'search_content', 'trending_topic_click' ...,
-- searching activity is maked by 'search_content', trending activity is marked by 'trending_topic_click'

WITH search_session AS (
  SELECT
    user_id,
    session_id,
    COUNT(*) AS search_number
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
  WHERE event_name = 'search_content'
  GROUP BY session_id, user_id
),
trending_session AS (
  SELECT
    user_id,
    session_id,
    COUNT(*) AS trending_number
  FROM `lighton-crm.lighton_technews_dwh.user_event_tracking`
  WHERE event_name = 'trending_topic_click'
  GROUP BY session_id, user_id
),
search_trending AS (
  SELECT
    COALESCE(S.user_id, T.user_id) AS user_id,
    session_id,
    search_number,
    trending_number
  FROM search_session AS S
  FULL JOIN trending_session AS T
  USING(session_id)  
)

-- Q 4.1: On average, how many times searching/trending function is used each session?
-- SELECT
--   SUM(search_number) AS total_search,
--   COUNT(search_number) AS number_session_search,
--   ROUND(AVG(search_number), 2) AS search_per_sess,
--   SUM(trending_number) AS total_trending,
--   COUNT(trending_number) AS number_session_trending,
--   ROUND(AVG(trending_number), 2) AS trending_per_sess
-- FROM search_trending

-- Q 4.2: Per user_id, how many times searching/trending function is used each session?
SELECT
  user_id,
  SUM(search_number) AS total_search,
  COUNT(search_number) AS number_session_search,
  ROUND(AVG(search_number), 2) AS search_per_sess,
  SUM(trending_number) AS total_trending,
  COUNT(trending_number) AS number_session_trending,
  ROUND(AVG(trending_number), 2) AS trending_per_sess
FROM search_trending
WHERE user_id != 3 --Exclude not-logged-in users
GROUP BY user_id
ORDER BY user_id