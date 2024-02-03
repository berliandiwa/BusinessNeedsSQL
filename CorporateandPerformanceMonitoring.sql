-- The Question
-- A.1 
-- The stakeholders want to know the Top 5 Categories with the highest total transactions from the entire given data, ensuring that the data is non-refundable. 
This will help determine which categories are dominant among buyers during that period.

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
    '2022-12-31' as current_datee
FROM `bitlabs-dab.G_CID_01.rfm_analysis`
)
SELECT cat_name, COUNT(DISTINCT order_id) total_order
FROM st
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Interpretation
/* The reporting results indicate that the top 5 categories with the highest number of orders are Agriculture & Food, Computer & Communication, Automotive & Transportation, 
 Machinery & Industrial Parts, and Electronics. Based on these results, it can be concluded that:
1. The majority of PT XYZ's customers come from the Agriculture & Food industry.
2. The largest profits for PT XYZ come from these 5 categories.
3. The sales trend on PT XYZ from 2018-2022 is dominated by products in the categories of Agriculture & Food, Computer & Communication, Automotive & Transportation, 
    Machinery & Industrial Parts, and Electronics. Therefore, PT XYZ can provide better treatment, both for sellers and transactions, in these categories.
*/

/* A.2 Stakeholders want to know the Year-over-Year (YoY) trend of Gross Merchandise Value (GMV) on PT XYZ.com for the years 2018, 2019, 2020, and 2021 for 4 prioritized 
segments: F&B (Agriculture & Food, Horeca), MRO (Machinery & Industrial Parts, Building Materials, Automotive & Transportation), Health & Beauty (Health & Medicare, Beauty 
Sport and Fashion), 3C (Computer & Communication, Electronics), and Others. */

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
gmv AS (
  SELECT CASE
            WHEN cat_name in ('Horeca','Agriculture & Food') THEN 'F & B'
            WHEN cat_name in ('Machinery & Industrial Parts', 'Building Materials', 'Automotive & Transportation')  
            THEN 'MRO'
            WHEN cat_name in ('Health & Medical', 'Beauty, Sport & Fashion') THEN 'Health & Beauty'
            WHEN cat_name in ('Computer & Communication', 'Electronics','Office & Store Supplies','Furnitures & Decorations','Services') THEN '3C & Others'
          END AS segments,
         EXTRACT(YEAR FROM order_datetime) year,
         SUM(gmv) total_gmv
  FROM st
  GROUP BY 1,2  
)
SELECT segments, 
       year,
       total_gmv,       
       CONCAT(ROUND((total_gmv - LAG(total_gmv) OVER (PARTITION BY segments ORDER BY year))
        /LAG(total_gmv) OVER (PARTITION BY segments ORDER BY year)*100,2),'%') AS pct_change_YoY
FROM gmv
WHERE segments IS NOT NULL;

/* Interpretation : 
Based on the reporting results, it can be concluded that:

1. The YoY GMV trend in the F&B segment experienced the highest increase in 2020 and the lowest decrease in 2021.
2. The YoY GMV trend in the MRO segment experienced the highest increase in 2021 and a decrease in 2019.
3. The YoY GMV trend in the Health & Beauty segment experienced the highest increase in 2021 and the highest decrease in 2020.
4. The YoY GMV trend in the 3C & Other segment experienced the highest increase in 2021 and a decrease in 2020.
5. The majority of segments experienced an increase in GMV in 2021, indicating that PT XYZ gained the highest profit in 2021.
6. The MRO segment experienced development for three consecutive years, from 2020 to 2022.
7. In 2022, all segments on PT XYZ experienced significant development, as evidenced by the positive YoY GMV growth for all segments.
8. In 2019, three out of four segments on PT XYZ, namely F&B, MRO, and Health & Beauty, experienced a decrease, resulting in an overall decrease in transactions 
for PT XYZ in 2019.*/
