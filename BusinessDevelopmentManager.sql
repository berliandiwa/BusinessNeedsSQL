/* Stakeholders want to know the number of buyers based on Bucket Size. They want to divide the total number of buyers based on the GMV and Total Transactions recorded 
from 2018 to 2022 into several groups to see the proportion of our buyers. Students are expected to differentiate them from the perspective of the 4 main Category segments 
that are prioritized (F&B, MRO, Health & Beauty, 3C & Others).*/

-- Kategori F&B
WITH st AS 
(
SELECT 
    order_id, 
    user_id, 
    order_source, 
    cat_name, 
    CASE 
        WHEN gmv LIKE '%,%' THEN CAST(REPLACE(gmv,',','.') AS FLOAT64)
        WHEN gmv LIKE '%.%.%' THEN CAST(REPLACE(gmv,'.','') AS FLOAT64)
        ELSE CAST(gmv AS FLOAT64)
    END AS gmv, 
    order_datetime, 
    rejected_datetime, 
    platform_source,
    user_last_login_datetime,
    user_register_datetime,
FROM `bitlabs-dab.G_CID_01.rfm_analysis`
),
-- Menjumlahkan jumlah transaksi dan jumlah gmv berdasarkan user untuk kategori F&B
sum_gmv AS(
SELECT
  user_id,
  COUNT(DISTINCT order_id) trans,
  SUM(gmv) total_gmv
FROM st 
WHERE cat_name in ('Horeca','Agriculture & Food') 
GROUP BY 1
ORDER BY 3 DESC
),
-- Mengelompokkan gmv
cat_gmv AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv BETWEEN 500000000 AND 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv BETWEEN 1000000000 AND 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv BETWEEN 2000000000 AND 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
GROUP BY 1
),
-- mengelompokkan gmv untuk jumlah transaksi <10
trans1 AS (
SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv BETWEEN 500000000 AND 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv BETWEEN 1000000000 AND 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv BETWEEN 2000000000 AND 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans<10
GROUP BY 1
),
-- Mengelompokkan jumlah gmv untuk transaksi antara 10-20 kali
trans2 AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv BETWEEN 500000000 AND 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv BETWEEN 1000000000 AND 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv BETWEEN 2000000000 AND 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans BETWEEN 10 AND 20
GROUP BY 1
),
-- Mengelompokkan jumlah gmv untuk transaksi antara 21-30 kali 
trans3 AS (
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv BETWEEN 500000000 AND 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv BETWEEN 1000000000 AND 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv BETWEEN 2000000000 AND 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans BETWEEN 20 AND 30
GROUP BY 1
),
-- Mengelompokkan jumlah gmv untuk transaksi antara 31-40 kali
trans4 AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >= 500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans BETWEEN 30 AND 40
GROUP BY 1
),
-- Mengelompokkan jumlah gmv untuk transaksi antara >40 kali
trans5 AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >= 500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans>40
GROUP BY 1
)
-- Menggabungkan kelima tabel tersebut 
SELECT cat_gmv.kategori_gmv, 
       trans1.total_user cat_trans1, 
       trans2.total_user cat_trans2,
       trans3.total_user cat_trans3, 
       trans4.total_user cat_trans4, 
       trans5.total_user cat_trans5
FROM cat_gmv
LEFT JOIN trans1
  ON cat_gmv.kategori_gmv = trans1.kategori_gmv
LEFT JOIN trans2
  ON cat_gmv.kategori_gmv = trans2.kategori_gmv
LEFT JOIN trans3
  ON cat_gmv.kategori_gmv = trans3.kategori_gmv
LEFT JOIN trans4
  ON cat_gmv.kategori_gmv = trans4.kategori_gmv
LEFT JOIN trans5
  ON cat_gmv.kategori_gmv = trans5.kategori_gmv
ORDER BY 1;

-- Kategori MRO
WITH st AS 
(
SELECT 
    order_id, 
    user_id, 
    order_source, 
    cat_name, 
    CASE 
        WHEN gmv LIKE '%,%' THEN CAST(REPLACE(gmv,',','.') AS FLOAT64)
        WHEN gmv LIKE '%.%.%' THEN CAST(REPLACE(gmv,'.','') AS FLOAT64)
        ELSE CAST(gmv AS FLOAT64)
    END AS gmv,
    order_datetime, 
    rejected_datetime, 
    platform_source,
    user_last_login_datetime,
    user_register_datetime,
FROM `bitlabs-dab.G_CID_01.rfm_analysis`
),
sum_gmv AS(
SELECT
  user_id,
  COUNT(order_id) trans,
  SUM(gmv) total_gmv
FROM st 
WHERE cat_name in ('Machinery & Industrial Parts', 'Building Materials', 'Automotive & Transportation')
GROUP BY 1
),
cat_gmv AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
GROUP BY 1
),
trans1 AS (
SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans<10
GROUP BY 1
),
trans2 AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans>=10 AND trans<=20
GROUP BY 1
),
trans3 AS (
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans>20 AND trans <=30
GROUP BY 1
),
trans4 AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans>30 AND trans <=40
GROUP BY 1
),
trans5 AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans>40
GROUP BY 1
)
SELECT cat_gmv.kategori_gmv, trans1.total_user cat_trans1, trans2.total_user cat_trans2, trans3.total_user cat_trans3, trans4.total_user cat_trans4, trans5.total_user cat_trans5
FROM cat_gmv
LEFT JOIN trans1
  ON cat_gmv.kategori_gmv = trans1.kategori_gmv
LEFT JOIN trans2
  ON cat_gmv.kategori_gmv = trans2.kategori_gmv
LEFT JOIN trans3
  ON cat_gmv.kategori_gmv = trans3.kategori_gmv
LEFT JOIN trans4
  ON cat_gmv.kategori_gmv = trans4.kategori_gmv
LEFT JOIN trans5
  ON cat_gmv.kategori_gmv = trans5.kategori_gmv
WHERE cat_gmv.kategori_gmv IS NOT NULL
ORDER BY 1;

-- Kategori Health & Beauty
WITH st AS 
(
SELECT 
    order_id, 
    user_id, 
    order_source, 
    cat_name, 
    CASE 
        WHEN gmv LIKE '%,%' THEN CAST(REPLACE(gmv,',','.') AS FLOAT64)
        WHEN gmv LIKE '%.%.%' THEN CAST(REPLACE(gmv,'.','') AS FLOAT64)
        ELSE CAST(gmv AS FLOAT64)
    END AS gmv,
    order_datetime, 
    rejected_datetime, 
    platform_source,
    user_last_login_datetime,
    user_register_datetime,
FROM `bitlabs-dab.G_CID_01.rfm_analysis`
),
sum_gmv AS(
SELECT
  user_id,
  COUNT(DISTINCT order_id) trans,
  SUM(gmv) total_gmv
FROM st 
WHERE cat_name in ('Health & Medical', 'Beauty, Sport & Fashion')
GROUP BY 1
),
cat_gmv AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
GROUP BY 1
),
trans1 AS (
SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans<10
GROUP BY 1
),
trans2 AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans>=10 AND trans<=20
GROUP BY 1
),
trans3 AS (
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans>20 AND trans <=30
GROUP BY 1
),
trans4 AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans>30 AND trans <=40
GROUP BY 1
),
trans5 AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans>40
GROUP BY 1
)
SELECT cat_gmv.kategori_gmv, 
       trans1.total_user cat_trans1, 
       trans2.total_user cat_trans2, 
       trans3.total_user cat_trans3, 
       trans4.total_user cat_trans4, 
       trans5.total_user cat_trans5
FROM cat_gmv
LEFT JOIN trans1
  ON cat_gmv.kategori_gmv = trans1.kategori_gmv
LEFT JOIN trans2
  ON cat_gmv.kategori_gmv = trans2.kategori_gmv
LEFT JOIN trans3
  ON cat_gmv.kategori_gmv = trans3.kategori_gmv
LEFT JOIN trans4
  ON cat_gmv.kategori_gmv = trans4.kategori_gmv
LEFT JOIN trans5
  ON cat_gmv.kategori_gmv = trans5.kategori_gmv
WHERE cat_gmv.kategori_gmv IS NOT NULL
ORDER BY 1;

-- Kategori 3C & Others
WITH st AS 
(
SELECT 
    order_id, 
    user_id, 
    order_source, 
    cat_name, 
    CASE 
        WHEN gmv LIKE '%,%' THEN CAST(REPLACE(gmv,',','.') AS FLOAT64)
        WHEN gmv LIKE '%.%.%' THEN CAST(REPLACE(gmv,'.','') AS FLOAT64)
        ELSE CAST(gmv AS FLOAT64)
    END AS gmv,
    order_datetime, 
    rejected_datetime, 
    platform_source,
    user_last_login_datetime,
    user_register_datetime,
FROM `bitlabs-dab.G_CID_01.rfm_analysis`
),
sum_gmv AS(
SELECT
  user_id,
  COUNT(DISTINCT order_id) trans,
  SUM(gmv) total_gmv
FROM st 
WHERE cat_name in ('Computer & Communication', 'Electronics','Office & Store Supplies','Furnitures & Decorations',
'Services')
GROUP BY 1
),
cat_gmv AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
GROUP BY 1
),
trans1 AS (
SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans<10
GROUP BY 1
),
trans2 AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans>=10 AND trans<=20
GROUP BY 1
),
trans3 AS (
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans>20 AND trans <=30
GROUP BY 1
),
trans4 AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans>30 AND trans <=40
GROUP BY 1
),
trans5 AS(
  SELECT CASE 
        WHEN total_gmv < 500000000 THEN " < 500 Million IDR"
        WHEN total_gmv >=500000000 AND total_gmv < 1000000000 THEN "500 Million - 1 Billion IDR"
        WHEN total_gmv >= 1000000000 AND total_gmv < 2000000000 THEN "1-2 Billion IDR"
        WHEN total_gmv >= 2000000000 AND total_gmv < 3000000000 THEN "2-3 Billion IDR"
        WHEN total_gmv >= 3000000000 THEN "> 3 Billion IDR"
       END AS kategori_gmv,
       COUNT(DISTINCT user_id) total_user
FROM sum_gmv
WHERE trans>40
GROUP BY 1
)
SELECT cat_gmv.kategori_gmv, 
       trans1.total_user cat_trans1, 
       trans2.total_user cat_trans2, 
       trans3.total_user cat_trans3, 
       trans4.total_user cat_trans4, 
       trans5.total_user cat_trans5
FROM cat_gmv
LEFT JOIN trans1
  ON cat_gmv.kategori_gmv = trans1.kategori_gmv
LEFT JOIN trans2
  ON cat_gmv.kategori_gmv = trans2.kategori_gmv
LEFT JOIN trans3
  ON cat_gmv.kategori_gmv = trans3.kategori_gmv
LEFT JOIN trans4
  ON cat_gmv.kategori_gmv = trans4.kategori_gmv
LEFT JOIN trans5
  ON cat_gmv.kategori_gmv = trans5.kategori_gmv
WHERE cat_gmv.kategori_gmv IS NOT NULL
ORDER BY 1;

/*Interpretation : 
F&B Category :
1. The F&B segment only has 2 GMV categories, which are less than 500 million and more than 3 billion.
2. The F&B segment has the highest number of users with a GMV value of less than 500 million and less than 10 transactions.
3. In the F&B segment, PT XYZ  has a relatively high proportion of buyers, indicating that PT XYZ  has many unique customers with few transactions. This is evident in the 
   highest number of users falling into the category of less than 10 transactions (infrequent transactions).

MRO Category: 
1. The MRO segment has 3 GMV categories: less than 500 million, 500 million - 1 billion, and more than 3 billion.
2. Customers with a total GMV of more than 3 billion are mostly unique customers (not retention customers), as seen from the highest number of customers falling into the
   category of less than 10 transactions.
3. The number of customers with a total GMV of more than 3 billion is the highest compared to other categories.
4. PT XYZ  can provide rewards, such as discounts or free membership, for customers with a total GMV of more than 3 billion, and customers who are frequent transactors 
 (categories of 30-40 transactions and more than 40 transactions) can be rewarded.

Health & Beauty Category :
1. The Health & Medical segment only has 2 GMV categories: less than 500 million and more than 3 billion.
2. The Health & Medical segment has the highest number of users with a GMV value of less than 500 million and less than 10 transactions.
3. In the Health & Medical segment, customers with a total GMV of more than 3 billion are the most numerous for total transactions of 10-20 times, 20-30 times, 30-40 times, 
   and more than 40 times.
4. For a total GMV of more than 3 billion, PT XYZ  has the most comprehensive customers in all transaction categories compared to other segments.
5. The Health & Medical segment has the highest number of retention customers compared to other segments. This is evident in the number of customers who complete their 
   transactions.

3C & Others :
1. The 3C & Others segment has 4 GMV categories: less than 500 million, 500 million - 1 billion, 1 - 2 billion, and more than 3 billion.
2. The 3C & Others segment has the highest number of users with a GMV value of less than 500 million and less than 10 transactions.
3. In the 3C & Others segment, customers with a total GMV of more than 3 billion are the most numerous for total transactions of 10-20 times, 20-30 times, 30-40 times, 
and more than 40 times.

Conclusion:

PT XYZ  has more unique customers (few transactions) than retention customers (customers with repeated transactions). This indicates a low level of customer loyalty that 
needs to be improved to support PT XYZ's sales. Customer loyalty can be built by providing rewards, improving services, enhancing product quality, offering promotions or 
discounts, conducting special campaigns for existing customers, and more.
*/
