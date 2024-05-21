WITH orders_array AS (
  SELECT
    DATE(timestamp) AS date,
    CAST(document_id AS INT64) AS order_id,
    ARRAY (
      SELECT CAST(JSON_EXTRACT_SCALAR(types, '$.bouquetPrice') AS FLOAT64) 
      FROM UNNEST(JSON_EXTRACT_ARRAY(data, '$.boxes')) AS boxes, 
          UNNEST(JSON_EXTRACT_ARRAY(boxes, '$.types')) AS types
    ) AS bouquetPrice_array,
    ARRAY(
      SELECT CAST(JSON_EXTRACT_SCALAR(types, '$.count') AS INT64) 
      FROM UNNEST(JSON_EXTRACT_ARRAY(data, '$.boxes')) AS boxes, 
          UNNEST(JSON_EXTRACT_ARRAY(boxes, '$.types')) AS types
    ) AS count_array,
    ARRAY(
      SELECT CAST((CAST(JSON_EXTRACT_SCALAR(types, '$.bouquetPrice') AS FLOAT64) * CAST(JSON_EXTRACT_SCALAR(types, '$.count') AS INT64)) AS FLOAT64) 
      FROM UNNEST(JSON_EXTRACT_ARRAY(data, '$.boxes')) AS boxes, 
          UNNEST(JSON_EXTRACT_ARRAY(boxes, '$.types')) AS types
    ) AS price_array,
    ARRAY(
      SELECT JSON_EXTRACT_SCALAR(types, '$.type') 
      FROM UNNEST(JSON_EXTRACT_ARRAY(data, '$.boxes')) AS boxes, 
           UNNEST(JSON_EXTRACT_ARRAY(boxes, '$.types')) AS types
    ) AS type_array,
    ARRAY(
      SELECT CAST(REGEXP_EXTRACT(JSON_EXTRACT_SCALAR(types, '$.type'), r'(.*?) - ') AS STRING) 
      FROM UNNEST(JSON_EXTRACT_ARRAY(data, '$.boxes')) AS boxes, 
          UNNEST(JSON_EXTRACT_ARRAY(boxes, '$.types')) AS types
    ) AS genuses_array,
    ARRAY(
      SELECT CAST(REGEXP_EXTRACT(JSON_EXTRACT_SCALAR(types, '$.type'), r' - (.*?) - ') AS STRING) 
      FROM UNNEST(JSON_EXTRACT_ARRAY(data, '$.boxes')) AS boxes, 
          UNNEST(JSON_EXTRACT_ARRAY(boxes, '$.types')) AS types
    ) AS grades_array,
    ARRAY(
      SELECT CAST(REGEXP_EXTRACT(JSON_EXTRACT_SCALAR(types, '$.type'), r'[^-]+ - ([^-]+)$') AS STRING) 
      FROM UNNEST(JSON_EXTRACT_ARRAY(data, '$.boxes')) AS boxes, 
          UNNEST(JSON_EXTRACT_ARRAY(boxes, '$.types')) AS types
    ) AS variants_array,
    CASE WHEN JSON_EXTRACT_SCALAR(data, '$.paid') = 'true' THEN 1
        WHEN JSON_EXTRACT_SCALAR(data, '$.paid') = 'false' THEN 0 END AS paid_flag,
    CAST(JSON_EXTRACT_SCALAR(data, '$.totalPrice') AS FLOAT64) AS total_price,
    CAST(JSON_EXTRACT_SCALAR(JSON_EXTRACT_ARRAY(data, '$.boxes')[0], '$.shipper') AS STRING) AS shipper,
    CAST(JSON_EXTRACT_SCALAR(JSON_EXTRACT_ARRAY(data, '$.boxes')[0], '$.pricePerKilo') AS INT64) AS price_per_kilo,
    CAST(JSON_EXTRACT_SCALAR(JSON_EXTRACT_ARRAY(data, '$.boxes')[0], '$.weight') AS FLOAT64) AS weight,
    CAST(JSON_EXTRACT_SCALAR(data, '$.shippingFee') AS FLOAT64) AS shipping_fee,

    CAST(JSON_EXTRACT_SCALAR(data, '$.campaign') AS STRING) AS campaign,
    CAST(JSON_EXTRACT_SCALAR(data, '$.deductions') AS STRING) AS deductions,
  FROM `fusheng-96fc5.firestore_export.orders_raw_latest`
  WHERE document_id != '--stats--'    --This row gives, e.g. 2024-02-28: {"totalNumberOfOrders":3326}
  ORDER BY timestamp DESC  
)

, orders AS (
  SELECT
    date,
    order_id,

    types,
    genuses,
    grades,
    variants,
    bouquet_price,
    counts,
    price_per_type,

    paid_flag,
    total_price AS order_total_price,
    shipper,
    price_per_kilo AS ship_price_per_kilo,
    weight AS ship_weight,
    shipping_fee AS order_shipping_fee,
    campaign,
    deductions
  FROM 
    orders_array,
    UNNEST(bouquetPrice_array) AS bouquet_price WITH OFFSET
  JOIN UNNEST(count_array) AS counts WITH OFFSET
  USING(OFFSET)
  JOIN UNNEST(price_array) AS price_per_type WITH OFFSET
  USING(OFFSET)
  JOIN UNNEST(type_array) AS types WITH OFFSET
  USING(OFFSET)
  JOIN UNNEST(genuses_array) AS genuses WITH OFFSET
  USING(OFFSET)
  JOIN UNNEST(grades_array) AS grades WITH OFFSET
  USING(OFFSET)
  JOIN UNNEST(variants_array) AS variants WITH OFFSET
  USING(OFFSET)  
)

, accounting AS (
  SELECT
    DATE(timestamp) AS date,
    document_id,
    CAST(JSON_EXTRACT_SCALAR(data, '$.orderId') AS INT64) AS order_id,
    CAST(JSON_EXTRACT_SCALAR(data, '$.amount') AS FLOAT64) AS amount,
    CAST(JSON_EXTRACT_SCALAR(data, '$.category') AS STRING) AS category,
    CAST(JSON_EXTRACT_SCALAR(data, '$.customer') AS STRING) AS customer,
    CASE WHEN CAST(JSON_EXTRACT_SCALAR(data, '$.isCustomer') AS STRING) = 'true' THEN 1
         WHEN CAST(JSON_EXTRACT_SCALAR(data, '$.isCustomer') AS STRING) = 'false' THEN 0 END AS customer_flag,
    CAST(REGEXP_EXTRACT(JSON_EXTRACT_SCALAR(data, '$.note'), r'marked as (.*?)\.') AS STRING) AS note,
    CAST(JSON_EXTRACT_SCALAR(data, '$.person') AS STRING) AS person,
    CAST(JSON_EXTRACT_SCALAR(data, '$.type') AS STRING) AS type
  FROM `fusheng-96fc5.firestore_export.accounting_raw_latest`
)

SELECT
  orders.date,
  orders.order_id,

  types,
  genuses,
  grades,
  variants,
  bouquet_price,
  counts,
  price_per_type,

  paid_flag,
  order_total_price,
  shipper,
  ship_price_per_kilo,
  ship_weight,
  order_shipping_fee,
  campaign,
  deductions,

  category,
  person,
  customer_flag,
  type
FROM orders
LEFT JOIN accounting USING (order_id)
ORDER BY orders.date DESC, orders.order_id