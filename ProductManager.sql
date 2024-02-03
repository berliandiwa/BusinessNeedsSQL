/* Stakeholders want to know the Success Order Rate for each order conducted by buyers grouped by Category, and an order is considered successful if it is 'Non Refund'.*/

WITH table1 AS 
(
  SELECT cat_name,
         COUNT (DISTINCT order_id) total_order,
         COUNT(DISTINCT IF(rejected_datetime IS NULL,order_id,NULL)) AS succeseed_order,
         COUNT (DISTINCT IF(rejected_datetime IS NOT NULL, order_id,NULL)) AS canceled_order
  FROM `bitlabs-dab.G_CID_01.rfm_analysis`
  GROUP BY cat_name 
)
SELECT cat_name,
       total_order,
       succeseed_order,
       canceled_order,
       CONCAT(ROUND((succeseed_order/total_order)*100,2),'%') succeseed_order_rate
FROM table1;

/* Interpretation : 

From the data available to Ralali, all categories have a certain number of cancelled or refunded orders by buyers, making it impossible to meet the standard success rate set.

When comparing the succeeded order with the total order, the Agriculture & Food, Electronics, Computer & Communication, Automotive & Transportation, Machinery & Industrial 
Parts, Health & Medical, Building Materials, and Horeca categories have a fairly high success order rate, which is above 95%. This indicates a high level of efficiency or 
success in the ordering and product delivery process within these categories, which should be maintained.

On the other hand, the Beauty, Services, Furniture & Decorations, and Office & Store Supplies categories have a lower success order rate, below 95%. Further observation is 
needed to determine and evaluate the reasons for the lower success rate compared to other categories.

The category with the lowest success order rate is Office & Store Supplies with a percentage of 86.74%. This indicates that many customers are dissatisfied with the service 
and ordering process in this category. Therefore, Ralali needs to evaluate the reasons for the low success order rate in the Office & Store Supplies category.
*/

-- Stakeholders want to know the Success Order Rate for each order conducted by buyers grouped by Category and Order Platform Source Class.
WITH table1 AS 
(
  SELECT cat_name,
         CASE
            WHEN platform_source in ('website', 'CMS','PWA') THEN 'Website'
            WHEN platform_source in ('ios', 'agent','Android') THEN 'Mobile'
            ELSE 'Website'
          END AS platform_source_class,
         COUNT (DISTINCT order_id) total_order,
         COUNT (DISTINCT IF(rejected_datetime IS NULL,order_id,NULL)) AS succeseed_order,
         COUNT (DISTINCT IF(rejected_datetime IS NOT NULL,order_id,NULL)) AS canceled_order
  FROM `bitlabs-dab.G_CID_01.rfm_analysis`
  GROUP BY 1,2
)
SELECT cat_name,
       platform_source_class,
       total_order,
       succeseed_order,
       canceled_order,
       CONCAT(ROUND((succeseed_order/total_order)*100,2),'%') succeseed_order_rate
FROM table1
ORDER BY 1,2 DESC;

/* Interpretation: 

Based on the categories, 18 out of 24 categories divided into each platform have a success order rate above 95%, while 6 of them have a success order rate below 95%. 
The highest percentage is in the Horeca category on the mobile platform with a percentage of 100%. This indicates that the mobile platform for the Horeca category has a good 
success order rate. Meanwhile, the lowest percentage is in the Office & Store Supplies category on the website platform with a percentage of 86.14%.

Looking at the average percentage of platform usage, the website platform usage percentage is 96.15% and the mobile platform usage percentage is 95.75%. However, in terms of 
the total number of orders for each platform, the total orders on the website platform reach 28,104 orders, while the total orders on the mobile platform are only 11,123
orders. This indicates that the majority of customers prefer and are more satisfied with using the website platform compared to the mobile platform. It suggests that the 
website platform performs better and is easier to use, making customers more interested in transacting through that platform.

To address the low number of orders and success order percentage on the mobile platform, Ralali needs to observe and reevaluate to identify any shortcomings that need to be 
addressed, thus improving the performance and success order rate on the mobile platform. Additionally, Ralali can introduce its mobile platform to customers to increase 
usage or total orders on the mobile platform.

*/
