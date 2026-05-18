-- Copying Files

\copy staging.orders
FROM 'original_data_files/orders.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

\copy staging.customers
FROM 'original_data_files/customers.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

\copy staging.order_items
FROM 'original_data_files/order_items.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

\copy staging.order_payments
FROM 'original_data_files/order_payments.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

\copy staging.reviews
FROM 'original_data_files/reviews.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

\copy staging.products
FROM 'original_data_files/products.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

\copy staging.product_category_name_translation
FROM 'original_data_files/product_category_name_translation.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

\copy staging.sellers
FROM 'original_data_files/sellers.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

\copy staging.geolocation
FROM 'original_data_files/geolocation.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Verifying Row Count

SELECT COUNT(*) FROM staging.orders;
SELECT COUNT(*) FROM staging.customers;
SELECT COUNT(*) FROM staging.order_items;
SELECT COUNT(*) FROM staging.order_payments;
SELECT COUNT(*) FROM staging.reviews;
SELECT COUNT(*) FROM staging.products;
SELECT COUNT(*) FROM staging.product_category_name_translation;
SELECT COUNT(*) FROM staging.sellers;
SELECT COUNT(*) FROM staging.geolocation;

-- Done

-- Checking for null values

SELECT COUNT(*) AS total_rows,
       COUNT(order_id) AS non_null_orders,
       COUNT(customer_id) AS non_null_customers,
       COUNT(order_purchase_timestamp) AS non_null_purchase_dates
FROM staging.orders;


SELECT COUNT(*) AS total_rows,
       COUNT(customer_id) AS non_null_customers,
       COUNT(customer_unique_id) AS non_null_unique_customers
FROM staging.customers;

SELECT COUNT(*) AS total_rows,
       COUNT(product_id) AS non_null_products,
       COUNT(product_category_name) AS non_null_categories,
       COUNT(product_weight_g) AS non_null_weight
FROM staging.products;

SELECT product_id, COUNT(*)
FROM staging.products
GROUP BY product_id
HAVING COUNT(*) > 1;

-- Checking Valid Date ranges

SELECT MIN(order_purchase_timestamp) AS earliest_order, 
       MAX(order_purchase_timestamp) AS latest_order
FROM staging.orders;


SELECT MIN(review_creation_date) AS earliest_review, 
       MAX(review_creation_date) AS latest_review
FROM staging.reviews;

-- Detecting Duplicate Primary Keys

SELECT order_id, COUNT(*)
FROM staging.orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT customer_id, COUNT(*)
FROM staging.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Checking for Outliers

SELECT MIN(product_weight_g) AS min_weight,
       MAX(product_weight_g) AS max_weight
FROM staging.products;

SELECT MIN(freight_value) AS min_freight,
       MAX(freight_value) AS max_freight
FROM staging.olist_order_items;

-- Products table's category field had null values. Fixing the null values within Product table by setting values as unknown

UPDATE staging.products
SET product_category_name = 'unknown'
WHERE product_category_name IS NULL;

-- Checking median of product_weight_g and imputing it with the median weight

SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY product_weight_g) 
FROM staging.products
WHERE product_weight_g IS NOT NULL;

UPDATE staging.products
SET product_weight_g = (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY product_weight_g) 
                        FROM staging.products WHERE product_weight_g IS NOT NULL)
WHERE product_weight_g IS NULL;

-- Query to check if all NULL values have been handles

SELECT product_id, COUNT(*)
FROM staging.products
GROUP BY product_id
HAVING COUNT(*) > 1; -- no null values
