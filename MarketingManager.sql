-- D.1 Stakeholders want to know the list of active buyers who have transacted in the last 6 months.

WITH st AS 
(
SELECT 
    order_id, 
    user_id, 
    order_source, 
    cat_name, 
    CASE 
        WHEN gmv LIKE '%,%' THEN SAFE_CAST(REPLACE(gmv,',','.') AS NUMERIC)
        ELSE SAFE_CAST(gmv AS NUMERIC)
    END AS gmv, 
    CAST (order_datetime AS DATETIME) order_datetime, 
    rejected_datetime, 
    platform_source,
    user_last_login_datetime,
    user_register_datetime
 FROM `bitlabs-dab.G_CID_01.rfm_analysis`
),

table1 AS(
    SELECT 
        user_id, 
        cat_name, 
        COUNT(order_id) frekuensi 
        FROM st 
    GROUP BY 1,2
    ORDER BY 1
),
table2 AS(
    SELECT user_id,
           cat_name,
           frekuensi,
           DENSE_RANK() OVER(PARTITION BY user_id ORDER BY frekuensi DESC,cat_name ASC) ranking
    FROM table1
    GROUP BY 1,2,frekuensi
    ORDER BY 3 DESC
),
table3 AS(
    SELECT 
        user_id, 
        MAX(order_datetime) last_order, 
        cat_name,
        DENSE_RANK() OVER(PARTITION BY user_id ORDER BY  MAX(order_datetime) DESC, cat_name ASC) ranking2
    FROM st
    GROUP BY 1,cat_name
),
table4 AS(
    SELECT 
        user_id, 
        SUM(gmv) gmv
    FROM st
    GROUP BY 1
)
SELECT st.user_id, 
       MAX(st.order_datetime) last_order,
       CASE     
            WHEN DATE_DIFF(DATETIME '2022-12-31', MAX(st.order_datetime),DAY) <7 THEN "<1 week"
            WHEN DATE_DIFF(DATETIME '2022-12-31', MAX(st.order_datetime),DAY) BETWEEN 7 AND 31 THEN "<1 month"
            WHEN DATE_DIFF(DATETIME '2022-12-31', MAX(st.order_datetime),DAY) BETWEEN 31 AND 62 THEN "<2 months"
            WHEN DATE_DIFF(DATETIME '2022-12-31', MAX(st.order_datetime),DAY) BETWEEN 62 AND 92 THEN "<3 months"
            WHEN DATE_DIFF(DATETIME '2022-12-31', MAX(st.order_datetime),DAY) BETWEEN 92 AND 183 THEN "<6 months"
        END AS last_order_date_class,
        table2.cat_name Top_frequently_category_order_lifetime,
        table3.cat_name Last_category_order,
        table4.gmv Total_gmv_lifetime
FROM st
JOIN table2
    ON st.user_id = table2.user_id
JOIN table3
    ON st.user_id = table3.user_id
JOIN table4
    ON st.user_id = table4.user_id
WHERE table2.ranking=1 AND table3.ranking2=1
GROUP BY st.user_id,4,5,6
ORDER BY 2 DESC,1;

/*Interpreation : 
1. The majority of PT XYZ's customers have been inactive for more than 6 months, indicating a relatively high churn rate. Therefore, the marketing manager can create a 
program to attract inactive customers to return to transact on PT XYZ.
2. From the generated data, the Agriculture & Food category is the most ordered category by customers.
3. Based on the query results, there are 27 out of 19,268 distinct users who are still actively transacting in the last 6 months. In response to these results, the marketing
manager can create a customer loyalty program such as rewards, special discounts, or gifts for customers who have completed transactions with a certain frequency or amount. 
This is a form of appreciation for their support and loyalty. This strategy can improve customer retention and encourage users to continue shopping on the platform due to 
the benefits they receive.
4. The results of top_frequently_category_order and last_category_order can be used to improve product sales and attract new customers or inactive old customers. Strategies
to increase orders based on this data can be implemented by displaying relevant items related to the top product orders (overall) and last product orders of each customer on 
the platform's homepage. Additionally, offering discounts on these products on certain days can increase product demand.
*/

-- D.2 Stakeholders want to know the list of buyers who have become inactive on the platform, defined as those who have not logged in for the past 6 months.
WITH st AS 
(
SELECT 
    order_id, 
    user_id, 
    order_source, 
    cat_name, 
    CASE 
        WHEN gmv LIKE '%,%' THEN SAFE_CAST(REPLACE(gmv,',','.') AS NUMERIC)
        ELSE SAFE_CAST(gmv AS NUMERIC)
    END AS gmv, 
    order_datetime, 
    rejected_datetime, 
    platform_source,
    CAST(user_last_login_datetime AS DATETIME)user_last_login_datetime ,
    user_register_datetime
 FROM `bitlabs-dab.G_CID_01.rfm_analysis`
),
table1 AS(
    SELECT 
        user_id, 
        cat_name, 
        COUNT(order_id) frekuensi 
        FROM st 
    GROUP BY 1,2
    ORDER BY 1
),
table2 AS(
    SELECT user_id,
           cat_name,
           frekuensi,
           DENSE_RANK() OVER(PARTITION BY user_id ORDER BY frekuensi DESC,cat_name ASC) ranking
    FROM table1
    GROUP BY 1,2,frekuensi
    ORDER BY 3 DESC
),
table3 AS(
    SELECT 
        user_id, 
        MAX(order_datetime) last_order, 
        cat_name,
        DENSE_RANK() OVER(PARTITION BY user_id ORDER BY  MAX(order_datetime) DESC, cat_name ASC) ranking2
    FROM st
    GROUP BY 1,cat_name
),
table4 AS(
    SELECT 
        user_id, 
        SUM(gmv) gmv
    FROM st
    GROUP BY 1
)
SELECT st.user_id, 
       MAX(st.user_last_login_datetime) last_login_date,
       CASE     
            WHEN DATE_DIFF(DATETIME '2022-12-31', MAX(st.user_last_login_datetime),MONTH) BETWEEN 6 AND 9 THEN ">6 months"
            WHEN DATE_DIFF(DATETIME '2022-12-31', MAX(st.user_last_login_datetime),MONTH) BETWEEN 10 AND 12 THEN ">9 months"
            WHEN DATE_DIFF(DATETIME '2022-12-31', MAX(st.user_last_login_datetime),MONTH) BETWEEN 13 AND 15 THEN ">12 months"
            WHEN DATE_DIFF(DATETIME '2022-12-31', MAX(st.user_last_login_datetime),MONTH) BETWEEN 16 AND 18 THEN ">15 months"
            WHEN DATE_DIFF(DATETIME '2022-12-31', MAX(st.user_last_login_datetime),MONTH) BETWEEN 19 AND 21 THEN ">18 months"
            WHEN DATE_DIFF(DATETIME '2022-12-31', MAX(st.user_last_login_datetime),MONTH) BETWEEN 22 AND 24 THEN ">21 months"
            WHEN DATE_DIFF(DATETIME '2022-12-31', MAX(st.user_last_login_datetime),MONTH) >24 THEN ">24 months"
            ELSE NULL
        END AS last_login_date_class,
        table2.cat_name Top_frequently_category_order_lifetime,
        table3.cat_name Last_category_order,
        table4.gmv Total_gmv_lifetime
FROM st
JOIN table2
    ON st.user_id = table2.user_id
JOIN table3
    ON st.user_id = table3.user_id
JOIN table4
    ON st.user_id = table4.user_id
WHERE table2.ranking=1 AND table3.ranking2 = 1
GROUP BY st.user_id,4,5,6
HAVING last_login_date_class IS NOT NULL
ORDER BY 6 DESC;

/* Interpretation : 
1. Based on the query results, there are 17,078 distinct users who have been inactive in transacting for more than 2 years, and the majority have not logged in for more than 
   2 years. In response to the high number of inactive users, the marketing manager can conduct promotions for inactive customers based on the available data, considering 
   products relevant to each customer's last_category_order. Promotions can include offering product discounts and sending notifications to each customer to encourage repeat 
   orders and return transactions on PT XYZ.
2. The marketing manager can create a reactivation program for inactive customers to encourage them to transact again or at least re-login to the PT XYZ platform. 
   Reactivation programs can include offering the benefits of PT XYZ's services or products to attract customers to re-login and transact again. Additionally, PT XYZ can 
   offer special discounts for products relevant to each customer's top frequently ordered items.
*/

