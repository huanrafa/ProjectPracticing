WITH dashboard AS (
  SELECT
    created_date_time,
    delivery_date,
    order_id,
    status_code,
    status_name,
    private_description,

    products.product_id,
    products.product_name,
    products.product_code,
    products.quantity,
    products.price,
    products.discount

  FROM `x-data-platform.x_nhanhvn_dwh.nhanhvn_order`
  CROSS JOIN UNNEST(products) AS products
)

, clone_product AS (
  SELECT
    product_id,
    CONCAT('Product NHANH.VN ', ROW_NUMBER() OVER (ORDER BY product_id)) AS product_code_clone,
    (10000+ROW_NUMBER() OVER (ORDER BY product_id)) AS product_id_clone,
  FROM
  (
    SELECT DISTINCT product_id
    FROM `x-data-platform.x_nhanhvn_dwh.nhanhvn_order`
    CROSS JOIN UNNEST(products) AS products
  )
)

, clone_order AS (
  SELECT
    order_id,
    (100000+ROW_NUMBER() OVER (ORDER BY order_id)) AS order_id_clone,
  FROM
  (
    SELECT DISTINCT order_id
    FROM dashboard 
  )
)

SELECT
  created_date_time,
  delivery_date,
  order_id_clone AS order_id,
  status_code,
  status_name,
  private_description,

  ARRAY_AGG(STRUCT(
    product_id_clone AS product_id,
    REGEXP_EXTRACT(product_name, r'^(.*?)\s*\(') AS product_name,
    product_code_clone AS product_code,
    quantity,
    price*2 AS price,
    CASE WHEN discount*3 < price*2 THEN discount*3
        ELSE price*2 END AS discount
  )) AS products,
FROM dashboard
LEFT JOIN clone_product USING(product_id)
LEFT JOIN clone_order USING(order_id)
GROUP BY ALL