-- **THIS IS NOT MY ORIGINAL DATA, used solutions for assistance as needed
-- ** UDEMY IS RESPONSIBLE
-- COURSE: Advanced SQL: MySQL Data Analysis & Business Intelligence
-- by Maven Analytics, John Pauler

-- ------------------------------------------------
-- SUBJECT: Board Meeting Next Week
--                                                  November 27, 2012
-- Good morning,

-- I need some help preparing a presentation for the board meeting next week.

-- The board would like to have a better understanding of our growth story over our first 
-- 8 months.  This will also be a good excuse to show off our analytical capabilities a bit.

-- -Cindy
-- --------------------------------------------------------------------------




-- 1. Gsearch seems to be the biggest driver of our business.  Could you pull MONTHLY TRENDS for 
--  GSEARCH SESSIONS AND ORDERS so that we can showcase the growth there?

USE mavenfuzzyfactory;

SELECT MIN(DATE(created_at)) AS start_date,
COUNT(website_session_id) AS sessions,           -- to count total sessions
COUNT(order_id) AS orders,                       -- to count total orders
COUNT(order_id)/COUNT(website_session_id) AS order_rate        -- order rate
FROM(                                            -- subquery is optional
    SELECT  ws.website_session_id,
    ws.created_at,
    o.order_id
    FROM website_sessions ws
    LEFT JOIN orders o ON                           -- LEFT join to see sessions with null orders
    o.website_session_id = ws.website_session_id  
    WHERE ws.created_at < '2012-11-27'              -- email constraint
        AND utm_source = 'gsearch'                  -- email 
) AS temp

GROUP BY MONTH(created_at);   -- grouping by month to see total sessions and orders

-- OUTPUT:
-- +------------+----------+--------+------------+
-- | start_date | sessions | orders | order_rate |
-- +------------+----------+--------+------------+
-- | 2012-03-19 |     1860 |     60 |     0.0323 |
-- | 2012-04-01 |     3574 |     92 |     0.0257 |
-- | 2012-05-01 |     3410 |     97 |     0.0284 |
-- | 2012-06-01 |     3578 |    121 |     0.0338 |
-- | 2012-07-01 |     3811 |    145 |     0.0380 |
-- | 2012-08-01 |     4877 |    184 |     0.0377 |
-- | 2012-09-01 |     4491 |    188 |     0.0419 |
-- | 2012-10-01 |     5534 |    234 |     0.0423 |
-- | 2012-11-01 |     8889 |    373 |     0.0420 |
-- +------------+----------+--------+------------+
-- ----------------------------------------------------------------------------------------------




-- 2. Next, it would be great to see a similar monthly trend for Gsearch, but this time SPLITTING
--  OUT NONBRAND and BRAND CAMPAIGNS SEPERATELY. I am wondering if brand is picking up at all.  
--  If so, this is a good story to tell.

USE mavenfuzzyfactory;

SELECT MIN(DATE(ws.created_at)) AS start_date,
COUNT(CASE WHEN utm_campaign = 'brand' THEN ws.website_session_id ELSE NULL END)
    AS brand_sessions,
COUNT(CASE WHEN utm_campaign = 'brand' THEN o.order_id ELSE NULL END)
    AS brand_orders,
COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN ws.website_session_id ELSE NULL END)
    AS nonbrand_sessions,
COUNT(CASE WHEN utm_campaign = 'nonbrand' THEN o.order_id ELSE NULL END)
    AS nonbrand_orders
FROM website_sessions ws
LEFT JOIN orders o ON 
o.website_session_id = ws.website_session_id
WHERE ws.created_at < '2012-11-27'
    AND utm_source = 'gsearch'
GROUP BY MONTH(DATE(ws.created_at));

-- OUTPUT:
-- +------------+----------------+--------------+-------------------+-----------------+
-- | start_date | brand_sessions | brand_orders | nonbrand_sessions | nonbrand_orders |
-- +------------+----------------+--------------+-------------------+-----------------+
-- | 2012-03-19 |              8 |            0 |              1852 |              60 |
-- | 2012-04-01 |             65 |            6 |              3509 |              86 |
-- | 2012-05-01 |            115 |            6 |              3295 |              91 |
-- | 2012-06-01 |            139 |            7 |              3439 |             114 |
-- | 2012-07-01 |            151 |            9 |              3660 |             136 |
-- | 2012-08-01 |            204 |           10 |              4673 |             174 |
-- | 2012-09-01 |            264 |           16 |              4227 |             172 |
-- | 2012-10-01 |            337 |           15 |              5197 |             219 |
-- | 2012-11-01 |            383 |           17 |              8506 |             356 |
+------------+----------------+--------------+-------------------+-----------------+
----------------------------------------------------------------------------------------------------




-- 3. While we're on Gsearch, could you dive into nonbrand, and pull MONTHLY SESSIONS AND ORDERS
--  SPLIT BY DEVICE TYPE? I want to flex our analytical muscles a little and show the board we really
--  know our traffic sources.

USE mavenfuzzyfactory;

SELECT MIN(DATE(ws.created_at)) AS start_date,
COUNT(CASE WHEN device_type = 'mobile' THEN ws.website_session_id ELSE NULL END)
    AS mobile_sessions,
COUNT(CASE WHEN device_type = 'mobile' THEN order_id ELSE NULL END)
    AS mobile_orders,
COUNT(CASE WHEN device_type = 'desktop' THEN ws.website_session_id ELSE NULL END)
    AS desktop_sessions,
COUNT(CASE WHEN device_type = 'desktop' THEN order_id ELSE NULL END)
    AS desktop_orders
FROM website_sessions ws
LEFT JOIN orders o ON           -- LEFT join very important
o.website_session_id = ws.website_session_id
WHERE ws.created_at < '2012-11-27'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY MONTH(DATE(ws.created_at));

-- OUTPUT:
-- +------------+-----------------+---------------+------------------+----------------+
-- | start_date | mobile_sessions | mobile_orders | desktop_sessions | desktop_orders |
-- +------------+-----------------+---------------+------------------+----------------+
-- | 2012-03-19 |             724 |            10 |             1128 |             50 |
-- | 2012-04-01 |            1370 |            11 |             2139 |             75 |
-- | 2012-05-01 |            1019 |             8 |             2276 |             83 |
-- | 2012-06-01 |             766 |             8 |             2673 |            106 |
-- | 2012-07-01 |             886 |            14 |             2774 |            122 |
-- | 2012-08-01 |            1158 |             9 |             3515 |            165 |
-- | 2012-09-01 |            1056 |            17 |             3171 |            155 |
-- | 2012-10-01 |            1263 |            18 |             3934 |            201 |
-- | 2012-11-01 |            2049 |            33 |             6457 |            323 |
-- +------------+-----------------+---------------+------------------+----------------+
----------------------------------------------------------------------------------------------------




-- 4. I'm worried that one of our more pessimistic board members may be concerned about the large % 
--  of traffic from Gsearch. Can you pull MONTHLY TRENDS FOR GSEARCH, ALONGSIDE MONTHLY TRENDS FOR
--  EACH OF OUR OTHER CHANNELS?

USE mavenfuzzyfactory;

SELECT utm_source, utm_campaign, http_referer  -- finding channels
FROM website_sessions
WHERE created_at < '2012-11-27'
GROUP BY 1,2,3;

-- +------------+--------------+-------------------------+
-- | utm_source | utm_campaign | http_referer            |
-- +------------+--------------+-------------------------+
-- | gsearch    | nonbrand     | https://www.gsearch.com |
-- | NULL       | NULL         | NULL                    |
-- | gsearch    | brand        | https://www.gsearch.com |
-- | NULL       | NULL         | https://www.gsearch.com |
-- | bsearch    | brand        | https://www.bsearch.com |
-- | NULL       | NULL         | https://www.bsearch.com |
-- | bsearch    | nonbrand     | https://www.bsearch.com |
-- +------------+--------------+-------------------------+

SELECT MIN(DATE(ws.created_at)) AS start_date,
COUNT(CASE WHEN utm_source = 'gsearch' THEN ws.website_session_id ELSE NULL END)
    AS gsearch_sessions,
COUNT(CASE WHEN utm_source = 'bsearch' THEN ws.website_session_id ELSE NULL END)
    AS bsearch_sessions,
COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN ws.website_session_id ELSE NULL END)
    AS organic_search_sessions,
COUNT(CASE WHEN  utm_source IS NULL AND http_referer IS NULL  THEN ws.website_session_id ELSE NULL END)
    AS direct_type_in_sessions

FROM website_sessions ws
WHERE ws.created_at < '2012-11-27'
GROUP BY MONTH(DATE(ws.created_at));

-- OUTPUT:
-- +------------+------------------+------------------+-------------------------+-------------------------+
-- | start_date | gsearch_sessions | bsearch_sessions | organic_search_sessions | direct_type_in_sessions |
-- +------------+------------------+------------------+-------------------------+-------------------------+
-- | 2012-03-19 |             1860 |                2 |                       8 |                       9 |
-- | 2012-04-01 |             3574 |               11 |                      78 |                      71 |
-- | 2012-05-01 |             3410 |               25 |                     150 |                     151 |
-- | 2012-06-01 |             3578 |               25 |                     190 |                     170 |
-- | 2012-07-01 |             3811 |               44 |                     207 |                     187 |
-- | 2012-08-01 |             4877 |              705 |                     265 |                     250 |
-- | 2012-09-01 |             4491 |             1439 |                     331 |                     285 |
-- | 2012-10-01 |             5534 |             1781 |                     428 |                     440 |
-- | 2012-11-01 |             8889 |             2840 |                     536 |                     485 |
-- +------------+------------------+------------------+-------------------------+-------------------------+
-----------------------------------------------------------------------------------------------------------




-- 5. I'd like to tell the story of our website performance improvements over the course of the
--  first 8 months. Could you pull SESSION TO ORDER CONVERSION RATES BY MONTH?

USE mavenfuzzyfactory;

SELECT MIN(DATE(ws.created_at)) AS start_date,
COUNT(ws.website_session_id) AS sessions,
COUNT(order_id) AS orders,
COUNT(order_id)/COUNT(ws.website_session_id) AS conv_rate
FROM website_sessions ws
LEFT JOIN orders o ON
ws.website_session_id = o.website_session_id
WHERE ws.created_at BETWEEN '2012-03-19' AND '2012-11-19'
GROUP BY MONTH(DATE(ws.created_at));

-- OUTPUT:
-- +------------+----------+--------+-----------+
-- | start_date | sessions | orders | conv_rate |
-- +------------+----------+--------+-----------+
-- | 2012-03-19 |     1879 |     60 |    0.0319 |
-- | 2012-04-01 |     3734 |     99 |    0.0265 |
-- | 2012-05-01 |     3736 |    108 |    0.0289 |
-- | 2012-06-01 |     3963 |    140 |    0.0353 |
-- | 2012-07-01 |     4249 |    169 |    0.0398 |
-- | 2012-08-01 |     6097 |    228 |    0.0374 |
-- | 2012-09-01 |     6546 |    287 |    0.0438 |
-- | 2012-10-01 |     8183 |    371 |    0.0453 |
-- | 2012-11-01 |     5044 |    232 |    0.0460 |
-- +------------+----------+--------+-----------+
-----------------------------------------------------------------------------------------------------------




-- 6. For the gsearch lander test, please ESTIMATE THE REVENUE THAT THE TEST EARNED US (hint: look at the 
--  increase in CVR from the test(jun19-jul28), and use nonbrand sessions and revenue since then to calculate
--  incremental value)

USE mavenfuzzyfactory;

SELECT MIN(website_pageview_id) AS min_lander_pageview
    FROM website_pageviews
WHERE pageview_url = '/lander-1';

-- +---------------------+
-- | min_lander_pageview |
-- +---------------------+
-- |               23504 |
-- +---------------------+

DROP TABLE IF EXISTS temp_table;
CREATE TEMPORARY TABLE temp_table
SELECT wp.website_session_id,
MIN(wp.website_pageview_id) AS min_pv -- landing page_view
FROM website_pageviews wp
JOIN website_sessions ws ON
ws.website_session_id = wp.website_session_id
WHERE ws.created_at < '2012-07-28'      -- email constraint
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
    AND wp.website_pageview_id >= 23504  -- first page view
GROUP BY 1;

-- +--------------------+--------+
-- | website_session_id | min_pv |
-- +--------------------+--------+
-- |              11683 |  23504 |
-- |              11684 |  23505 |
-- |              11685 |  23506 |
-- |              11686 |  23507 |
-- |              11687 |  23509 |
-- |              11688 |  23510 |
-- |              11689 |  23511 |
-- TO BE CONTINUED...

DROP TABLE IF EXISTS temp_table2;
CREATE TEMPORARY TABLE temp_table2
SELECT t.website_session_id,
wp.pageview_url AS landing_page -- landing_pageview to landing_page
FROM temp_table t
JOIN website_pageviews wp ON
wp.website_pageview_id = t.min_pv
WHERE wp.pageview_url IN ('/lander-1', '/home');  -- specifying

-- +--------------------+--------------+
-- | website_session_id | landing_page |
-- +--------------------+--------------+
-- |              11683 | /lander-1    |
-- |              11684 | /home        |
-- |              11685 | /lander-1    |
-- |              11686 | /lander-1    |
-- |              11687 | /home        |
-- |              11688 | /home        |
-- |              11689 | /lander-1    |
-- TO BE CONTINUED...
DROP TABLE IF EXISTS temp_table_w_orders;
CREATE TEMPORARY TABLE temp_table_w_orders
SELECT tt.website_session_id,
landing_page,
order_id
FROM temp_table2 tt
LEFT JOIN orders o ON
o.website_session_id = tt.website_session_id;

-- +--------------------+--------------+----------+
-- | website_session_id | landing_page | order_id |
-- +--------------------+--------------+----------+
-- |              11683 | /lander-1    |     NULL |
-- |              11684 | /home        |     NULL |
-- |              11685 | /lander-1    |     NULL |
-- |              11686 | /lander-1    |     NULL |
-- |              11687 | /home        |     NULL |
-- |              11688 | /home        |     NULL |
-- |              11689 | /lander-1    |     NULL |
-- TO BE CONTINUED...

SELECT two.landing_page,
COUNT(website_session_id) AS sessions,
COUNT(order_id) AS orders,
COUNT(order_id)/COUNT(website_session_id) AS conv_rate
FROM temp_table_w_orders two
GROUP BY 1;

-- +--------------+----------+--------+-----------+
-- | landing_page | sessions | orders | conv_rate |
-- +--------------+----------+--------+-----------+
-- | /lander-1    |     2316 |     94 |    0.0406 |
-- | /home        |     2261 |     72 |    0.0318 |
-- +--------------+----------+--------+-----------+
-- .0406-.0318 = .0088 

SELECT MAX(ws.website_session_id) AS most_recent_gsearch_nonbrand_home_pv
FROM website_sessions ws
JOIN website_pageviews wp ON
wp.website_session_id = ws.website_session_id
WHERE utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND pageview_url = '/home'
AND ws.created_at < '2012-11-27';

-- +--------------------------------------+
-- | most_recent_gsearch_nonbrand_home_pv |
-- +--------------------------------------+
-- |                                17145 |
-- +--------------------------------------+

SELECT COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
    AND website_session_id > 17145
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand';

-- +---------------------+
-- | sessions_since_test |
-- +---------------------+
-- |               22972 |
-- +---------------------+
-- 22972 x .0088 incremental conversion = 202 incremental orders since 7/29
-- roughly 4 months, so roughlt 50 extra orders per month. 
--  ----------------------------------------------------------------------------------------------------------




-- 7. For the landing page test you analyzed previously, it would be great to show a FULL CONVERSION FUNNEL
--  FROM EACH OF THE TWO PAGES TO ORDERS. you can use the same time period you analyzed last time (jun19-jul28).

USE mavenfuzzyfactory;

DROP TABLE IF EXISTS made_it2_progress;
CREATE TEMPORARY TABLE made_it2_progress
SELECT website_session_id,  -- creating query for grouping sessions, using max() to see how far it made it to
MAX(lander1_flag) AS made_it2_lander,
MAX(home_flag) AS made_it2_home,
MAX(products_flag) AS made_it2_products,
MAX(og_mrf_flag) AS made_it2_og_mrf,
MAX(cart_flag) AS made_it2_cart,
MAX(shipping_flag) AS made_it2_shipping,
MAX(billing_flag) AS made_it2_billing,
MAX(ty_flag) AS made_it2_ty
FROM
(SELECT wp.website_session_id,  -- creating subquery flag
wp.pageview_url,
wp.created_at,
CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander1_flag,
CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS home_flag,
CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_flag,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS og_mrf_flag,
CASE WHEN pageview_url =  '/cart' THEN 1 ELSE 0 END AS cart_flag,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_flag,
CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_flag,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS ty_flag
FROM website_pageviews wp
JOIN website_sessions ws ON
ws.website_session_id = wp.website_session_id       -- for email constraints
WHERE ws.created_at BETWEEN '2012-06-19' AND '2012-07-28'
    AND ws.utm_source = 'gsearch' 
    AND ws.utm_campaign = 'nonbrand'
ORDER BY ws.website_session_id, wp.created_at) AS temp
GROUP BY 1;     

--  +--------------------+-----------------+---------------+-------------------+-----------------+---------------+-------------------+------------------+-------------+
-- | website_session_id | made_it2_lander | made_it2_home | made_it2_products | made_it2_og_mrf | made_it2_cart | made_it2_shipping | made_it2_billing | made_it2_ty |
-- +--------------------+-----------------+---------------+-------------------+-----------------+---------------+-------------------+------------------+-------------+
-- |              11725 |               1 |             0 |                 1 |               1 |             0 |                 0 |                0 |           0 |
-- |              11727 |               0 |             1 |                 0 |               0 |             0 |                 0 |                0 |           0 |
-- |              11728 |               0 |             1 |                 1 |               0 |             0 |                 0 |                0 |           0 |
-- |              11729 |               1 |             0 |                 1 |               1 |             1 |                 1 |                1 |           1 |
-- TO BE CONTINUED...

DROP TABLE IF EXISTS total_table;
CREATE TEMPORARY TABLE total_table
SELECT 
CASE WHEN made_it2_lander = 1 THEN "lander"        -- group these
    WHEN made_it2_home =1 THEN "home"
    ELSE NULL END AS landing_page,
COUNT(CASE WHEN made_it2_lander =1 THEN website_session_id 
WHEN made_it2_home =1 THEN website_session_id ELSE NULL END) AS sessions,
COUNT(CASE WHEN made_it2_products =1 THEN website_session_id ELSE NULL END) AS products,
COUNT(CASE WHEN made_it2_og_mrf =1 THEN website_session_id ELSE NULL END) AS og_mrf,
COUNT(CASE WHEN made_it2_cart =1 THEN website_session_id ELSE NULL END) AS cart,
COUNT(CASE WHEN made_it2_shipping =1 THEN website_session_id ELSE NULL END) AS shipping,
COUNT(CASE WHEN made_it2_billing =1 THEN website_session_id ELSE NULL END) AS billing,
COUNT(CASE WHEN made_it2_ty =1 THEN website_session_id ELSE NULL END) AS ty
FROM made_it2_progress
GROUP BY 1;

-- +--------------+----------+----------+--------+------+----------+---------+----+
-- | landing_page | sessions | products | og_mrf | cart | shipping | billing | ty |
-- +--------------+----------+----------+--------+------+----------+---------+----+
-- | lander       |     2316 |     1083 |    772 |  348 |      231 |     197 | 94 |
-- | home         |     2261 |      942 |    684 |  296 |      200 |     168 | 72 |
-- +--------------+----------+----------+--------+------+----------+---------+----+

SELECT landing_page,
tot.products/tot.sessions AS session_to_product_clk_rate,
tot.og_mrf/tot.products AS product_to_ogmrf_clk_rate,
tot.cart/tot.og_mrf AS ogmrf_to_cart_clk_rate,
tot.shipping/tot.cart AS cart_to_shipping_clk_rate,
tot.billing/tot.shipping AS shipping_to_billing_clk_rate,
tot.ty/tot.billing AS billing_to_ty_clk_rate
FROM total_table tot;

-- +--------------+-----------------------------+---------------------------+------------------------+---------------------------+------------------------------+------------------------+
-- | landing_page | session_to_product_clk_rate | product_to_ogmrf_clk_rate | ogmrf_to_cart_clk_rate | cart_to_shipping_clk_rate | shipping_to_billing_clk_rate | billing_to_ty_clk_rate |
-- +--------------+-----------------------------+---------------------------+------------------------+---------------------------+------------------------------+------------------------+
-- | lander       |                      0.4676 |                    0.7128 |                 0.4508 |                    0.6638 |                       0.8528 |                 0.4772 |
-- | home         |                      0.4166 |                    0.7261 |                 0.4327 |                    0.6757 |                       0.8400 |                 0.4286 |
-- +--------------+-----------------------------+---------------------------+------------------------+---------------------------+------------------------------+------------------------+
----------------------------------------------------------------------------------------------------------




-- 8. I'd love for you to QUANTIFY THE IMPACT OF OUR BILLING TEST, as well. Please analyze the lift generated
--  from the test (sep10-nov10), in terms of REVENUE PER BILLING PAGE SESSION, and then pull the number of 
--  billing page sessions for the past month to understand monthly impact.

USE mavenfuzzyfactory;

SELECT b_page,
COUNT(website_session_id) AS pageviews,
SUM(price_usd)/COUNT(website_session_id) AS revenue_per_billingpage_seen
FROM
(SELECT wp.website_session_id,
wp.pageview_url AS b_page,
o.order_id,
o.price_usd
FROM website_pageviews wp
LEFT JOIN orders o ON
o.website_session_id = wp.website_session_id
WHERE wp.pageview_url IN('/billing','/billing-2')
    AND wp.created_at BETWEEN '2012-09-10' AND '2012-11-10') as temp
GROUP BY 1;

-- SUBQUERY OUTPUT:
-- +--------------------+------------+----------+-----------+
-- | website_session_id | b_page     | order_id | price_usd |
-- +--------------------+------------+----------+-----------+
-- |              25393 | /billing   |      876 |     49.99 |
-- |              25411 | /billing-2 |      877 |     49.99 |
-- |              25454 | /billing-2 |      878 |     49.99 |
-- |              25459 | /billing-2 |     NULL |      NULL |
-- |              25468 | /billing   |     NULL |      NULL |
-- |              25488 | /billing   |     NULL |      NULL |
-- |              25508 | /billing   |      879 |     49.99 |

-- ACTUAL OUTPUT:
-- +------------+-----------+------------------------------+
-- | b_page     | pageviews | revenue_per_billingpage_seen |
-- +------------+-----------+------------------------------+
-- | /billing-2 |       654 |                    31.339297 |
-- | /billing   |       657 |                    22.826484 |
-- +------------+-----------+------------------------------+