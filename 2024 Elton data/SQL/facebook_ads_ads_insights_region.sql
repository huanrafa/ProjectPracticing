WITH flatten_data AS (
  SELECT
    account_id,
    ad_id,
    date_start,
    region,

    -- outbound_clicks
    MAX(CASE WHEN JSON_VALUE(oc, '$.action_type') = 'outbound_click' THEN CAST(JSON_VALUE(oc, '$.value') AS FLOAT64) ELSE 0 END) AS outbound_clicks,

    -- actions
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'link_click' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS link_clicks,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'post_engagement' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS post_engagements,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'page_engagament' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS page_engagaments,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'post_reaction' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS post_reactions,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'comment' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS post_comments,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'landing_page_view' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS landing_page_views,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'photo_view' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS photo_views,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'video_view' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS video_views,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'view_content' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS view_contents,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'conversions' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS conversions,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'add_to_cart' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS action_add_to_cart,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'omni_add_to_cart' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS add_to_cart_action_count,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_web_add_to_cart' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS action_onsite_web_add_to_cart,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'purchase' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS action_purchase,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'offsite_conversion.fb_pixel_purchase' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS action_offsite_conversion_fb_pixel_purchase,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_web_purchase' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS action_onsite_web_purchase,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_web_app_purchase' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS action_onsite_web_app_purchase,

    -- message
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_conversion.messaging_order_created_v2' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS onsite_conversion_messaging_order_created_v2,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_conversion.messaging_first_reply' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS messaging_first_reply,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_conversion.total_messaging_connection' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS total_messaging_connection,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_conversion.messaging_user_conversation_depth_2_message_send' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS messaging_user_conversation_depth_2_message_send,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_conversion.messaging_conversation_started_7d' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS onsite_conversion_messaging_conversation_started_7d,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_conversion.messaging_conversation_replied_7d' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS onsite_conversion_messaging_conversation_replied_7d,
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_conversion.other' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS onsite_conversion_other,

    -- action_values
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'omni_add_to_cart' THEN CAST(JSON_VALUE(action_values, '$.value') AS INT64) ELSE 0 END) AS add_to_cart_action_value,

    -- converted_product_quantity
    MAX(CASE WHEN JSON_VALUE(cpq, '$.action_type') = 'omni_add_to_cart' THEN CAST(JSON_VALUE(cpq, '$.value') AS INT64) ELSE 0 END) AS converted_add_to_cart_quantity,
    MAX(CASE WHEN JSON_VALUE(cpq, '$.action_type') = 'omni_view_content' THEN CAST(JSON_VALUE(cpq, '$.value') AS INT64) ELSE 0 END) AS converted_content_views,
    MAX(CASE WHEN JSON_VALUE(cpq, '$.action_type') = 'omni_purchase' THEN CAST(JSON_VALUE(cpq, '$.value') AS INT64) ELSE 0 END) AS converted_purchase_quantity,
    MAX(CASE WHEN JSON_VALUE(cpq, '$.action_type') = 'converted_product_value' THEN CAST(JSON_VALUE(cpq, '$.value') AS INT64) ELSE 0 END) AS converted_product_value,
    MAX(CASE WHEN JSON_VALUE(cpq, '$.action_type') = 'conversion_values' THEN CAST(JSON_VALUE(cpq, '$.value') AS INT64) ELSE 0 END) AS converted_conversion_values,

    -- converted_product_value
    MAX(CASE WHEN JSON_VALUE(cpv, '$.action_type') = 'omni_add_to_cart' THEN CAST(JSON_VALUE(cpv, '$.value') AS INT64) ELSE 0 END) AS converted_add_to_cart_value,
    MAX(CASE WHEN JSON_VALUE(cpv, '$.action_type') = 'omni_purchase' THEN CAST(JSON_VALUE(cpv, '$.value') AS INT64) ELSE 0 END) AS converted_purchase_value,
    MAX(CASE WHEN JSON_VALUE(cpv, '$.action_type') = 'app_custom_event.fb_mobile_add_to_cart' THEN CAST(JSON_VALUE(cpv, '$.value') AS INT64) ELSE 0 END) AS converted_mobile_add_to_cart,
    MAX(CASE WHEN JSON_VALUE(cpv, '$.action_type') = 'app_custom_event.fb_mobile_purchase' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS converted_mobile_purchase,
    MAX(CASE WHEN JSON_VALUE(cpv, '$.action_type') = 'offsite_conversion.fb_pixel_add_to_cart' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS converted_offsite_conversion_fb_pixel_add_to_cart,
    MAX(CASE WHEN JSON_VALUE(cpv, '$.action_type') = 'offsite_conversion.fb_pixel_purchase' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS converted_offsite_conversion_fb_pixel_purchase,

    -- website CTR
    MAX(CASE WHEN JSON_VALUE(website_ctr, '$.action_type') = 'link_click' THEN CAST(JSON_VALUE(website_ctr, '$.value') AS FLOAT64) ELSE 0 END) AS website_ctr_link_click,

    -- Video views
    MAX(CASE WHEN JSON_VALUE(video_30_sec_watched_actions, '$.action_type') = 'video_view' THEN CAST(JSON_VALUE(video_30_sec_watched_actions, '$.value') AS FLOAT64) ELSE 0 END) AS video_30_sec_watched_actions,
    MAX(CASE WHEN JSON_VALUE(video_p100_watched_actions, '$.action_type') = 'video_view' THEN CAST(JSON_VALUE(video_p100_watched_actions, '$.value') AS FLOAT64) ELSE 0 END) AS video_p100_watched_actions,
    MAX(CASE WHEN JSON_VALUE(video_p25_watched_actions, '$.action_type') = 'video_view' THEN CAST(JSON_VALUE(video_p25_watched_actions, '$.value') AS FLOAT64) ELSE 0 END) AS video_p25_watched_actions,
    MAX(CASE WHEN JSON_VALUE(video_p50_watched_actions, '$.action_type') = 'video_view' THEN CAST(JSON_VALUE(video_p50_watched_actions, '$.value') AS FLOAT64) ELSE 0 END) AS video_p50_watched_actions,
    MAX(CASE WHEN JSON_VALUE(video_p75_watched_actions, '$.action_type') = 'video_view' THEN CAST(JSON_VALUE(video_p75_watched_actions, '$.value') AS FLOAT64) ELSE 0 END) AS video_p75_watched_actions,
    MAX(CASE WHEN JSON_VALUE(video_p95_watched_actions, '$.action_type') = 'video_view' THEN CAST(JSON_VALUE(video_p95_watched_actions, '$.value') AS FLOAT64) ELSE 0 END) AS video_p95_watched_actions,
    MAX(CASE WHEN JSON_VALUE(video_play_actions, '$.action_type') = 'video_view' THEN CAST(JSON_VALUE(video_play_actions, '$.value') AS FLOAT64) ELSE 0 END) AS video_play_actions,

    -- Conversion value count and value money
    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'omni_initiated_checkout' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS omni_initiated_checkout,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'omni_initiated_checkout' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS omni_initiated_checkout_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_web_app_view_content' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS onsite_web_app_view_content,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'onsite_web_app_view_content' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS onsite_web_app_view_content_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_web_app_add_to_cart' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS onsite_web_app_add_to_cart,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'onsite_web_app_add_to_cart' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS onsite_web_app_add_to_cart_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_web_app_purchase' THEN CAST(JSON_VALUE(action, '$.value') AS FLOAT64) ELSE 0 END) AS onsite_web_app_purchase,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'onsite_web_app_purchase' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS onsite_web_app_purchase_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_web_purchase' THEN CAST(JSON_VALUE(action, '$.value') AS FLOAT64) ELSE 0 END) AS onsite_web_purchase,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'onsite_web_purchase' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS onsite_web_purchase_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_web_add_to_cart' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS onsite_web_add_to_cart,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'onsite_web_add_to_cart' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS onsite_web_add_to_cart_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'onsite_web_view_content' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS onsite_web_view_content,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'onsite_web_view_content' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS onsite_web_view_content_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'add_payment_info' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS add_payment_info,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'add_payment_info' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS add_payment_info_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'offsite_conversion.fb_pixel_search' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS offsite_conversion_fb_pixel_search,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'offsite_conversion.fb_pixel_search' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS offsite_conversion_fb_pixel_search_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'offsite_conversion.fb_pixel_view_content' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS offsite_conversion_fb_pixel_view_content,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'offsite_conversion.fb_pixel_view_content' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS offsite_conversion_fb_pixel_view_content_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'offsite_conversion.fb_pixel_add_payment_info' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS offsite_conversion_fb_pixel_add_payment_info,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'offsite_conversion.fb_pixel_add_payment_info' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS offsite_conversion_fb_pixel_add_payment_info_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'offsite_conversion.fb_pixel_add_to_cart' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS offsite_conversion_fb_pixel_add_to_cart,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'offsite_conversion.fb_pixel_add_to_cart' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS offsite_conversion_fb_pixel_add_to_cart_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'offsite_conversion.fb_pixel_initiate_checkout' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS offsite_conversion_fb_pixel_initiate_checkout,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'offsite_conversion.fb_pixel_initiate_checkout' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS offsite_conversion_fb_pixel_initiate_checkout_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'offsite_conversion.fb_pixel_purchase' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS offsite_conversion_fb_pixel_purchase,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'offsite_conversion.fb_pixel_purchase' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS offsite_conversion_fb_pixel_purchase_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'initiate_checkout' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS initiate_checkout,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'initiate_checkout' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS initiate_checkout_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'omni_search' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS omni_search,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'omni_search' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS omni_search_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'purchase' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS purchase,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'purchase' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS purchase_value,

    MAX(CASE WHEN JSON_VALUE(action, '$.action_type') = 'omni_purchase' THEN CAST(JSON_VALUE(action, '$.value') AS INT64) ELSE 0 END) AS omni_purchase,
    MAX(CASE WHEN JSON_VALUE(action_values, '$.action_type') = 'omni_purchase' THEN CAST(JSON_VALUE(action_values, '$.value') AS FLOAT64) ELSE 0 END) AS omni_purchase_value,

    -- Some special campaigns
    MAX(CASE WHEN JSON_VALUE(catalog_segment_actions, '$.action_type') = 'add_to_cart' THEN CAST(JSON_VALUE(catalog_segment_actions, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_add_to_cart,
    MAX(CASE WHEN JSON_VALUE(catalog_segment_value, '$.action_type') = 'add_to_cart' THEN CAST(JSON_VALUE(catalog_segment_value, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_add_to_cart_value,

    MAX(CASE WHEN JSON_VALUE(catalog_segment_actions, '$.action_type') = 'app_custom_event.fb_mobile_add_to_cart' THEN CAST(JSON_VALUE(catalog_segment_actions, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_app_custom_event_fb_mobile_add_to_cart,
    MAX(CASE WHEN JSON_VALUE(catalog_segment_value, '$.action_type') = 'app_custom_event.fb_mobile_add_to_cart' THEN CAST(JSON_VALUE(catalog_segment_value, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_app_custom_event_fb_mobile_add_to_cart_value,

    MAX(CASE WHEN JSON_VALUE(catalog_segment_actions, '$.action_type') = 'app_custom_event.fb_mobile_content_view' THEN CAST(JSON_VALUE(catalog_segment_actions, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_app_custom_event_fb_mobile_content_view,
    MAX(CASE WHEN JSON_VALUE(catalog_segment_value, '$.action_type') = 'app_custom_event.fb_mobile_content_view' THEN CAST(JSON_VALUE(catalog_segment_value, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_app_custom_event_fb_mobile_content_view_value,

    MAX(CASE WHEN JSON_VALUE(catalog_segment_actions, '$.action_type') = 'offsite_conversion.fb_pixel_view_content' THEN CAST(JSON_VALUE(catalog_segment_actions, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_offsite_conversion_fb_pixel_view_content,
    MAX(CASE WHEN JSON_VALUE(catalog_segment_value, '$.action_type') = 'offsite_conversion.fb_pixel_view_content' THEN CAST(JSON_VALUE(catalog_segment_value, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_offsite_conversion_fb_pixel_view_content_value,

    MAX(CASE WHEN JSON_VALUE(catalog_segment_actions, '$.action_type') = 'omni_add_to_cart' THEN CAST(JSON_VALUE(catalog_segment_actions, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_omni_add_to_cart,
    MAX(CASE WHEN JSON_VALUE(catalog_segment_value, '$.action_type') = 'omni_add_to_cart' THEN CAST(JSON_VALUE(catalog_segment_value, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_omni_add_to_cart_value,

    MAX(CASE WHEN JSON_VALUE(catalog_segment_actions, '$.action_type') = 'omni_purchase' THEN CAST(JSON_VALUE(catalog_segment_actions, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_omni_purchase,
    MAX(CASE WHEN JSON_VALUE(catalog_segment_value, '$.action_type') = 'omni_purchase' THEN CAST(JSON_VALUE(catalog_segment_value, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_omni_purchase_value,

    MAX(CASE WHEN JSON_VALUE(catalog_segment_actions, '$.action_type') = 'omni_view_content' THEN CAST(JSON_VALUE(catalog_segment_actions, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_omni_view_content,
    MAX(CASE WHEN JSON_VALUE(catalog_segment_value, '$.action_type') = 'omni_view_content' THEN CAST(JSON_VALUE(catalog_segment_value, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_omni_view_content_value,

    MAX(CASE WHEN JSON_VALUE(catalog_segment_actions, '$.action_type') = 'offsite_conversion' THEN CAST(JSON_VALUE(catalog_segment_actions, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_offsite_conversion,
    MAX(CASE WHEN JSON_VALUE(catalog_segment_value, '$.action_type') = 'offsite_conversion' THEN CAST(JSON_VALUE(catalog_segment_value, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_offsite_conversion_value,

    MAX(CASE WHEN JSON_VALUE(catalog_segment_actions, '$.action_type') = 'onsite_web_app_view_content' THEN CAST(JSON_VALUE(catalog_segment_actions, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_onsite_web_app_view_content,
    MAX(CASE WHEN JSON_VALUE(catalog_segment_value, '$.action_type') = 'onsite_web_app_view_content' THEN CAST(JSON_VALUE(catalog_segment_value, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_onsite_web_app_view_content_value,

    MAX(CASE WHEN JSON_VALUE(catalog_segment_actions, '$.action_type') = 'onsite_web_view_content' THEN CAST(JSON_VALUE(catalog_segment_actions, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_onsite_web_view_content,
    MAX(CASE WHEN JSON_VALUE(catalog_segment_value, '$.action_type') = 'onsite_web_view_content' THEN CAST(JSON_VALUE(catalog_segment_value, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_onsite_web_view_content_value,

    MAX(CASE WHEN JSON_VALUE(catalog_segment_actions, '$.action_type') = 'onsite_app_view_content' THEN CAST(JSON_VALUE(catalog_segment_actions, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_onsite_app_view_content,
    MAX(CASE WHEN JSON_VALUE(catalog_segment_value, '$.action_type') = 'onsite_app_view_content' THEN CAST(JSON_VALUE(catalog_segment_value, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_onsite_app_view_content_value,

    MAX(CASE WHEN JSON_VALUE(catalog_segment_actions, '$.action_type') = 'onsite_web_app_add_to_cart' THEN CAST(JSON_VALUE(catalog_segment_actions, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_onsite_web_app_add_to_cart,
    MAX(CASE WHEN JSON_VALUE(catalog_segment_value, '$.action_type') = 'onsite_web_app_add_to_cart' THEN CAST(JSON_VALUE(catalog_segment_value, '$.value') AS FLOAT64) ELSE 0 END) AS catalog_segment_actions_onsite_web_app_add_to_cart_value,

  FROM `x-data-platform.x_facebookads_dwh.facebook_ads_ads_insights_region`
  LEFT JOIN UNNEST(outbound_clicks) AS oc
  LEFT JOIN UNNEST(actions) AS action
  LEFT JOIN UNNEST(action_values) AS action_values
  LEFT JOIN UNNEST(converted_product_quantity) AS cpq
  LEFT JOIN UNNEST(converted_product_value) AS cpv
  LEFT JOIN UNNEST(website_ctr) AS website_ctr
  LEFT JOIN UNNEST(video_30_sec_watched_actions) AS video_30_sec_watched_actions
  LEFT JOIN UNNEST(video_p100_watched_actions) AS video_p100_watched_actions
  LEFT JOIN UNNEST(video_p25_watched_actions) AS video_p25_watched_actions
  LEFT JOIN UNNEST(video_p50_watched_actions) AS video_p50_watched_actions
  LEFT JOIN UNNEST(video_p75_watched_actions) AS video_p75_watched_actions
  LEFT JOIN UNNEST(video_p95_watched_actions) AS video_p95_watched_actions
  LEFT JOIN UNNEST(video_play_actions) AS video_play_actions

  LEFT JOIN UNNEST(catalog_segment_actions) AS catalog_segment_actions
  LEFT JOIN UNNEST(catalog_segment_value) AS catalog_segment_value

  GROUP BY 1, 2, 3, 4
)

SELECT

  CAST(ai.date_start AS DATE) AS date_start,
  CAST(ai.date_stop AS DATE) AS date_stop,
  ai.account_id,
  ai.account_name,
  ai.campaign_id,
  ai.campaign_name,
  campaign.objective AS campaign_objective,
  campaign.configured_status AS campaign_configured_status,
  campaign.effective_status AS campaign_effective_status,
  ai.adset_id,
  ai.adset_name,
  ad_set.configured_status AS adset_configured_status,
  ad_set.effective_status AS adset_effective_status,
  ai.ad_id,
  ai.ad_name,
  ad.configured_status AS ad_configured_status,
  ad.effective_status AS ad_effective_status,
  clicks,
  impressions,
  reach,
  spend,
  social_spend,
  ai.region,
  flatten_data.* EXCEPT (account_id, ad_id, date_start)

FROM `x-data-platform.x_facebookads_dwh.facebook_ads_ads_insights_region` AS ai
LEFT JOIN `x-data-platform.x_facebookads_dwh.facebook_ads_ads` AS ad ON ai.ad_id = ad.id
LEFT JOIN `x-data-platform.x_facebookads_dwh.facebook_ads_ad_sets` AS ad_set ON ai.adset_id = ad_set.id
LEFT JOIN `x-data-platform.x_facebookads_dwh.facebook_ads_campaigns` AS campaign ON ai.campaign_id = campaign.id
LEFT JOIN flatten_data ON ai.account_id = flatten_data.account_id 
  AND ai.ad_id = flatten_data.ad_id
  AND ai.date_start = flatten_data.date_start
  AND ai.region = flatten_data.region

