WITH overall AS (
  SELECT
    record_date AS date,
    page_id,
    page_name,
  FROM `biv-data-platform.biv_facebook_pages_datamart.facebook_pages_insights_flatten`
  ORDER BY page_name, date DESC  
),

insight AS (
  SELECT * FROM `biv-data-platform.biv_facebook_pages_01_dwh.facebook_page_insights_daily`
  WHERE name = 'page_positive_feedback_by_type'
  UNION DISTINCT
  SELECT * FROM `biv-data-platform.biv_facebook_pages_02_dwh.facebook_page_insights_daily`
  WHERE name = 'page_positive_feedback_by_type'
),

positive_feedback AS (
  SELECT
    date,
    page_name,
    overall.page_id,
    value,
    COALESCE(CAST(JSON_EXTRACT_SCALAR(value, '$.like') AS INTEGER), 0) AS likes,
    COALESCE(CAST(JSON_EXTRACT_SCALAR(value, '$.comment') AS INTEGER), 0) AS comments,
    COALESCE(CAST(JSON_EXTRACT_SCALAR(value, '$.other') AS INTEGER), 0) AS others,
    COALESCE(CAST(JSON_EXTRACT_SCALAR(value, '$.link') AS INTEGER), 0) AS links,
    COALESCE(CAST(JSON_EXTRACT_SCALAR(value, '$.answer') AS INTEGER), 0) AS answers,
    COALESCE(CAST(JSON_EXTRACT_SCALAR(value, '$.claim') AS INTEGER), 0) AS claims,
    COALESCE(CAST(JSON_EXTRACT_SCALAR(value, '$.rsvp') AS INTEGER), 0) AS rsvp,
  FROM overall
  LEFT JOIN insight
  ON overall.page_id = insight.page_id
    AND overall.date = insight.record_date  
)

SELECT
  date,
  page_name,
  page_id,
  value,
  likes,
  comments,
  others,
  links,
  answers,
  claims,
  rsvp,
  (likes + comments + others + links + answers + claims + rsvp) AS total_positive_feedback
FROM positive_feedback
ORDER BY date DESC, page_name

