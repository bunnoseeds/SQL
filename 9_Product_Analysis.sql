-- **THIS IS NOT MY ORIGINAL DATA, used solutions for assistance as needed
-- ** UDEMY IS RESPONSIBLE
-- COURSE: Advanced SQL: MySQL Data Analysis & Business Intelligence
-- by Maven Analytics, John Pauler

-- KEY TERMS:
-- COUNT(order_id) = number of ORDERS placed by customers
-- SUM(price_usd) = REVENUE; Money the business brings in from orderes
-- SUM(price_usd - cogs_usd) = MARGIN; Revenue less the cost of goods sold
-- AVG(price_usd) = AOV;average revenue generated per order

-- --------------------------------------------------------------------------------------------
-- SUBJECT 1: Sales Trends
--                                                 January 04, 2013
-- Hi there,

-- We're about to launch a new product, and I'd like to do a deep dive on our current flagship
-- product. Can you please PULL MONTHLY TRENDS TO DATE FOR NUMBERS OF SALES, TOTAL REVENUE, 
-- and TOTAL MARGIN GENERATED for the business?

-- Thanks,
-- Cindy
-- --------------------------------------------------------------------------------------------
USE mavenfuzzyfactory;
SELECT MIN(DATE(created_at)) AS start_date,
COUNT(order_id) AS number_of_orders,
SUM(price_usd) AS revenue,
SUM(price_usd - cogs_usd) AS margin
FROM orders
WHERE created_at < '2013-01-04'
GROUP BY MONTH(DATE(created_at))
;

-- OUTPUT:
-- +------------+------------------+----------+----------+
-- | start_date | number_of_orders | revenue  | margin   |
-- +------------+------------------+----------+----------+
-- | 2012-03-19 |               60 |  2999.40 |  1830.00 |
-- | 2012-04-01 |               99 |  4949.01 |  3019.50 |
-- | 2012-05-01 |              108 |  5398.92 |  3294.00 |
-- | 2012-06-01 |              140 |  6998.60 |  4270.00 |
-- | 2012-07-01 |              169 |  8448.31 |  5154.50 |
-- | 2012-08-01 |              228 | 11397.72 |  6954.00 |
-- | 2012-09-01 |              287 | 14347.13 |  8753.50 |
-- | 2012-10-01 |              371 | 18546.29 | 11315.50 |
-- | 2012-11-01 |              618 | 30893.82 | 18849.00 |
-- | 2012-12-01 |              506 | 25294.94 | 15433.00 |
-- | 2013-01-01 |               42 |  2099.58 |  1281.00 |
-- +------------+------------------+----------+----------+
-- --------------------------------------------------------------------------------------------
-- SUBJECT 2: Impact of New Product launch
--                                                 April 05, 2013
-- Hi there,

-- We launched our second product back on January 6th. Can you pull together some trended analysis?

-- I'd like to see MONTHLY ORDER VOLUME, OVERALL CONVERSION RATES, REVENUE PER SESSION, and a 
-- BREAKDOWN OF SALES BY PRODUCT, all for the time period since April 1, 2012

-- Thanks,
-- Cindy
-- --------------------------------------------------------------------------------------------

USE mavenfuzzyfactory;
SELECT MIN(DATE(ws.created_at)) AS start_date,
COUNT(o.order_id) 
    AS order_volume,
COUNT(o.order_id)/COUNT(ws.website_session_id) 
    AS conv_rate,
SUM(o.price_usd)/COUNT(ws.website_session_id) 
    AS revenue_per_sessions,
COUNT(CASE WHEN primary_product_id = 1 THEN order_id ELSE NULL END) 
    AS product_one_orders, 
COUNT(CASE WHEN primary_product_id = 2 THEN order_id ELSE NULL END) 
    AS product_two_orders
FROM website_sessions ws    
LEFT JOIN orders o ON o.website_session_id = ws.website_session_id
WHERE ws.created_at BETWEEN '2012-04-01' AND '2013-04-05'
GROUP BY MONTH(DATE(ws.created_at))
;

-- OUTPUT:
-- +------------+--------------+-----------+----------------------+--------------------+--------------------+
-- | start_date | order_volume | conv_rate | revenue_per_sessions | product_one_orders | product_two_orders |
-- +------------+--------------+-----------+----------------------+--------------------+--------------------+
-- | 2012-04-01 |          195 |    0.0394 |             2.000415 |                181 |                 14 |
-- | 2012-05-01 |          108 |    0.0289 |             1.445107 |                108 |                  0 |
-- | 2012-06-01 |          140 |    0.0353 |             1.765985 |                140 |                  0 |
-- | 2012-07-01 |          169 |    0.0398 |             1.988305 |                169 |                  0 |
-- | 2012-08-01 |          228 |    0.0374 |             1.869398 |                228 |                  0 |
-- | 2012-09-01 |          287 |    0.0438 |             2.191740 |                287 |                  0 |
-- | 2012-10-01 |          371 |    0.0453 |             2.266441 |                371 |                  0 |
-- | 2012-11-01 |          618 |    0.0441 |             2.204969 |                618 |                  0 |
-- | 2012-12-01 |          506 |    0.0502 |             2.511412 |                506 |                  0 |
-- | 2013-01-01 |          391 |    0.0611 |             3.127025 |                344 |                 47 |
-- | 2013-02-01 |          497 |    0.0693 |             3.692108 |                335 |                162 |
-- | 2013-03-01 |          385 |    0.0615 |             3.176269 |                320 |                 65 |
-- +------------+--------------+-----------+----------------------+--------------------+--------------------+

-- Business Concept: Product level website analysis
-- Product-focused website analysis is about learning how customers interacti with each of your products
-- , and how well each product converts customers

-- --------------------------------------------------------------------------------------------
-- SUBJECT 3: Help w/ user pathing
--                                                 April 06, 2013
-- Hi there,

-- Now that we have a new product, i'm thinking about our user path and conversion funnel. Let's look
-- at SESSION WHICH HIT THE /PRODUCT PAGE AND SEE WHERE THEY WENT NEXT.

-- could you please pull CLICKTHROUGH RATES FROM /PRODUCTS SINCE THE NEW PRODUCT LAUNCH ON 
-- JANUARY 6TH 2013, by product, and COMPARE TO THE 3 MONTHS LEADING UP TO LAUNCH AS A BASELINE

-- Thanks,
-- Cindy
-- --------------------------------------------------------------------------------------------

-- step 1 finding relevant sessions
USE mavenfuzzyfactory;
DROP TABLE IF EXISTS product_pages;
CREATE TEMPORARY TABLE product_pages
SELECT website_session_id,          -- only finding product pages
website_pageview_id,
created_at,
CASE WHEN created_at BETWEEN '2013-01-06' AND '2013-04-06' THEN 'post'          -- adding pre or post launch column
WHEN created_at BETWEEN '2012-10-06' AND '2013-01-06' THEN 'pre' ELSE NULL END
    AS time_period
FROM website_pageviews 
WHERE created_at BETWEEN '2012-10-06' AND '2013-04-06'  -- filtering results
AND pageview_url = '/products';                         -- we only want to see product page sessions which we will use later to find the next page for those sessions.

-- +--------------------+---------------------+---------------------+-------------+
-- | website_session_id | website_pageview_id | created_at          | time_period |
-- +--------------------+---------------------+---------------------+-------------+
-- |              31517 |               67216 | 2012-10-06 00:01:26 | pre         |
-- |              31518 |               67220 | 2012-10-06 00:20:27 | pre         |
-- |              31519 |               67222 | 2012-10-06 00:24:31 | pre         |
-- |              31521 |               67227 | 2012-10-06 00:48:54 | pre         |
-- |              31524 |               67232 | 2012-10-06 01:50:14 | pre         |

-- step 2 finding next pages id
DROP TABLE IF EXISTS next_pages;
CREATE TEMPORARY TABLE next_pages
SELECT pp.time_period,         -- pp. not wp. bc pp is product page filtered wp. is all pages..
pp.website_session_id,          -- using pp.session_id bc we need product sessions (for joining later)
MIN(wp.website_pageview_id) AS next_page  -- using min() to find the lowest pageview_id out of all pageview_ids that are GREATER than the product pageviews but using pageview_url
FROM product_pages pp
LEFT JOIN website_pageviews wp ON
wp.website_session_id = pp.website_session_id      -- joining with website_pageviews to see all pages
AND pp.website_pageview_id < wp.website_pageview_id  -- filtering page views after products page so we can use min() to find NEXT page
GROUP BY 1,2;           -- grouping the pp.website_Sessions_id and pp.website_pageviews_id bc we only care ab sessions with product pages

-- changing 
DROP TABLE IF EXISTS next_pages_url;
CREATE TEMPORARY TABLE next_pages_url
SELECT np.time_period,         
np.website_session_id,          
wp.pageview_url AS next_page_url  
FROM next_pages np
LEFT JOIN website_pageviews wp ON
wp.website_pageview_id = np.next_page      --IMPORTANT
;
-- +-------------+--------------------+------------------------+
-- | time_period | website_session_id | pageview_url           |
-- +-------------+--------------------+------------------------+
-- | pre         |              31545 | /the-original-mr-fuzzy |
-- | pre         |              31549 | /the-original-mr-fuzzy |
-- | pre         |              31551 | NULL                   |
-- | pre         |              31552 | NULL                   |
-- | pre         |              31559 | /the-original-mr-fuzzy |


-- Step 3: aggregation
SELECT pp.time_period,
COUNT(pp.website_session_id) AS product_sessions,
COUNT(CASE WHEN npu.next_page_url IS NOT NULL THEN npu.website_session_id ELSE NULL END)
    AS w_next_page,
COUNT(CASE WHEN npu.next_page_url IS NOT NULL THEN npu.website_session_id ELSE NULL END)/COUNT(pp.website_session_id)
    AS pct_to_next_page,
COUNT(CASE WHEN npu.next_page_url = '/the-original-mr-fuzzy' THEN npu.website_session_id ELSE NULL END)
    AS mr_fuzzy,
COUNT(CASE WHEN npu.next_page_url = '/the-original-mr-fuzzy' THEN npu.website_session_id ELSE NULL END)/COUNT(pp.website_session_id)
    AS pct_to_mr_fuzzy,
COUNT(CASE WHEN npu.next_page_url = '/the-forever-love-bear' THEN npu.website_session_id ELSE NULL END)
    AS love_bear,
COUNT(CASE WHEN npu.next_page_url = '/the-forever-love-bear' THEN npu.website_session_id ELSE NULL END)/COUNT(pp.website_session_id)
    AS pct_to_love_bear

FROM product_pages pp
LEFT JOIN next_pages_url npu ON
npu.website_session_id = pp.website_session_id
GROUP BY 1;

-- OUTPUT:
-- +-------------+------------------+-------------+------------------+----------+-----------------+-----------+------------------+
-- | time_period | product_sessions | w_next_page | pct_to_next_page | mr_fuzzy | pct_to_mr_fuzzy | love_bear | pct_to_love_bear |
-- +-------------+------------------+-------------+------------------+----------+-----------------+-----------+------------------+
-- | pre         |            15696 |       11347 |           0.7229 |    11347 |          0.7229 |         0 |           0.0000 |
-- | post        |            10709 |        8200 |           0.7657 |     6654 |          0.6213 |      1546 |           0.1444 |
-- +-------------+------------------+-------------+------------------+----------+-----------------+-----------+------------------+
-- --------------------------------------------------------------------------------------------
-- SUBJECT 4: Product Conversion Funnels
--                                                 April 10, 2013
-- Hi there,

-- I'd like to look at our two products since January 6th and analyze the CONVERSION FUNNELS FROM
-- EACH PRODUCT PAGE TO CONVERSION

-- it would be great if you could produce a COMPARISON BETWEEN THE TWO CONVERSION FUNNELS, FOR ALL
-- WEBSITE TRAFFIC

-- Thanks,
-- Cindy
-- --------------------------------------------------------------------------------------------`

-- STEP 1: create flag subquery and made_it2 table
USE mavenfuzzyfactory;
DROP TABLE IF EXISTS made_it2_table;
CREATE TEMPORARY TABLE made_it2_table
SELECT website_session_id,      -- only thing that needs to be grouped
MAX(the_omrf_flag) AS made_it2_the_omrf,
MAX(the_flb_flag) AS made_it2_the_flb,
MAX(cart_flag) AS made_it2_cart,
MAX(billing_flag) AS made_it2_billing,
MAX(shipping_flag) AS made_it2_shipping,
MAX(tyfyo_flag) AS made_it2_tyfyo
FROM (
SELECT              -- creating subquery for flags to group
website_session_id,
website_pageview_id, 
created_at,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS the_omrf_flag,
CASE WHEN pageview_url = '/the-forever-love-bear' THEN 1 ELSE 0 END AS the_flb_flag,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_flag,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_flag,
CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_flag,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS tyfyo_flag
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10') AS TEMP
GROUP BY 1;

-- +--------------------+-------------------+------------------+---------------+------------------+-------------------+----------------+
-- | website_session_id | made_it2_the_omrf | made_it2_the_flb | made_it2_cart | made_it2_billing | made_it2_shipping | made_it2_tyfyo |
-- +--------------------+-------------------+------------------+---------------+------------------+-------------------+----------------+
-- |              63513 |                 1 |                0 |             1 |                1 |                 1 |              1 |
-- |              63514 |                 0 |                0 |             0 |                0 |                 0 |              0 |
-- |              63515 |                 1 |                0 |             1 |                0 |                 0 |              0 |
-- |              63516 |                 1 |                0 |             0 |                0 |                 0 |              0 |
-- |              63517 |                 1 |                0 |             0 |                0 |                 0 |              0 |

SELECT 
CASE WHEN made_it2_the_omrf = 1 THEN 'the_omrf' -- grouping both products and adding aggregation
WHEN made_it2_the_flb = 1 THEN 'the_flb' END
    AS product,
COUNT(website_session_id) AS sessions,
COUNT(CASE WHEN made_it2_cart THEN website_session_id ELSE NULL END)
    AS to_cart,
COUNT(CASE WHEN made_it2_shipping THEN website_session_id ELSE NULL END)
    AS to_shipping,
COUNT(CASE WHEN made_it2_billing THEN website_session_id ELSE NULL END)
    AS to_billing,
COUNT(CASE WHEN made_it2_tyfyo THEN website_session_id ELSE NULL END)
    AS to_tyfyo
FROM made_it2_table
GROUP BY 1;

-- -- OUTPUT:
-- +----------+----------+---------+-------------+------------+----------+
-- | product  | sessions | to_cart | to_shipping | to_billing | to_tyfyo |
-- +----------+----------+---------+-------------+------------+----------+
-- | the_omrf |     6985 |    3038 |        2084 |       1710 |     1088 |
-- | NULL     |    12563 |       0 |           0 |          0 |        0 |
-- | the_flb  |     1599 |     877 |         603 |        488 |      301 |
-- +----------+----------+---------+-------------+------------+----------+

-- ALTERNATE ----------------------------------------------------------------------------------------------------
-- STEP 1; select all pageviews for relevant sessions
DROP TABLE IF EXISTS products; 
CREATE TEMPORARY TABLE products
SELECT website_session_id,
website_pageview_id,
created_at,
CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN  '/the-original-mr-fuzzy'
WHEN pageview_url = '/the-forever-love-bear' THEN '/the-forever-love-bear'
ELSE NULL END AS product_seen
FROM website_pageviews
WHERE pageview_url IN ('/the-original-mr-fuzzy','/the-forever-love-bear')
AND created_at BETWEEN '2013-01-06' AND '2013-04-10';   -- email constraints

-- +--------------------+---------------------+---------------------+------------------------+
-- | website_session_id | website_pageview_id | created_at          | product_seen           |
-- +--------------------+---------------------+---------------------+------------------------+
-- |              64369 |              141027 | 2013-01-10 00:44:52 | /the-original-mr-fuzzy |
-- |              64370 |              141030 | 2013-01-10 00:50:13 | /the-forever-love-bear |
-- |              64372 |              141035 | 2013-01-10 01:18:17 | /the-original-mr-fuzzy |
-- |              64374 |              141042 | 2013-01-10 01:37:47 | /the-original-mr-fuzzy |

-- STEP 2: figure out which pageview urls to look for
DROP TABLE IF EXISTS next_sessions;
CREATE TEMPORARY TABLE next_sessions
SELECT p.product_seen,
p.website_session_id,
wp.pageview_url             -- finding pageview urls
FROM products p
LEFT JOIN website_pageviews wp ON
wp.website_session_id = p.website_session_id
AND wp.website_pageview_id > p.website_pageview_id;     -- finding the following pageviews for each session

-- +------------------------+--------------------+---------------------------+
-- | product_seen           | website_session_id | pageview_url              |
-- +------------------------+--------------------+---------------------------+
-- | /the-original-mr-fuzzy |              63513 | /cart                     |
-- | /the-original-mr-fuzzy |              63513 | /shipping                 |
-- | /the-original-mr-fuzzy |              63513 | /billing-2                |
-- | /the-original-mr-fuzzy |              63513 | /thank-you-for-your-order |
-- | /the-original-mr-fuzzy |              63515 | /cart                     |
-- | /the-original-mr-fuzzy |              63516 | NULL                      |

-- STEP 3: pull all pageviews and identify the funnel steps (flag)
DROP TABLE IF EXISTS made_it2_next_session;
CREATE TEMPORARY TABLE made_it2_next_session
SELECT website_session_id, product_seen,
MAX(cart_flag) AS made_it2_cart,
MAX(shipping_flag) AS made_it2_shipping,
MAX(billing_flag) AS made_it2_billing,
MAX(tyfyo_flag) AS made_it2_tyfyo
FROM
(SELECT website_session_id,      -- subquery flag
product_seen,
CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_flag,
CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_flag,
CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_flag,
CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS tyfyo_flag
FROM next_sessions ) AS temp
GROUP BY 1,2;

-- +--------------------+------------------------+---------------+-------------------+------------------+----------------+
-- | website_session_id | product_seen           | made_it2_cart | made_it2_shipping | made_it2_billing | made_it2_tyfyo |
-- +--------------------+------------------------+---------------+-------------------+------------------+----------------+
-- |              63513 | /the-original-mr-fuzzy |             1 |                 1 |                1 |              1 |
-- |              63515 | /the-original-mr-fuzzy |             1 |                 0 |                0 |              0 |
-- |              63516 | /the-original-mr-fuzzy |             0 |                 0 |                0 |              0 |

-- STEP 4: create the session-level conversion funnel view
SELECT
CASE WHEN product_seen = '/the-original-mr-fuzzy' THEN '/the-original-mr-fuzzy' 
WHEN product_seen = '/the-forever-love-bear' THEN '/the-forever-love-bear'
ELSE NULL END AS product,
COUNT(website_session_id) AS sessions,
COUNT(CASE WHEN made_it2_cart THEN website_session_id ELSE NULL END)
    AS to_cart,
COUNT(CASE WHEN made_it2_shipping THEN website_session_id ELSE NULL END)
    AS to_shipping,
COUNT(CASE WHEN made_it2_billing THEN website_session_id ELSE NULL END)
    AS to_billing,
COUNT(CASE WHEN made_it2_tyfyo THEN website_session_id ELSE NULL END)
    AS to_tyfyo
FROM made_it2_next_session
GROUP BY 1;

-- OUTPUT:
-- +------------------------+----------+---------+-------------+------------+----------+
-- | product                | sessions | to_cart | to_shipping | to_billing | to_tyfyo |
-- +------------------------+----------+---------+-------------+------------+----------+
-- | /the-original-mr-fuzzy |     6985 |    3038 |        2084 |       1710 |     1088 |
-- | /the-forever-love-bear |     1599 |     877 |         603 |        488 |      301 |
-- +------------------------+----------+---------+-------------+------------+----------+

-- Business Concept: cross-selling products
-- cross-sell analysis is about understanding which products users are most likely to purchase together.
-- and offering smart product recommendations

-- --------------------------------------------------------------------------------------------
-- SUBJECT 5: Cross_selling Performance
--                                                 November 22, 2013
-- Hi there,

-- On September 25th we started giving customers the OPTION TO ADD A 2ND PRODUCT WHILE ON THE 
-- /CART PAGE. morgan says this has been positive, but id like your take on it.

-- could you please COMPARE THE MONTH BEFORE VS THE MONTH AFTER THE CHANGE? i'd like to see
-- CTR FROM THE /CART PAGE, AVG PRODUCTS PER ORDER, AOV, AND OVERALL REVENUE PER /CART PAGE VIEW

-- Thanks,
-- Cindy
-- --------------------------------------------------------------------------------------------

-- step 1: find all cart sessions
USE mavenfuzzyfactory;
DROP TABLE IF EXISTS cart_sessions;
CREATE TEMPORARY TABLE cart_sessions
SELECT 
CASE WHEN created_at BETWEEN '2013-08-25' AND '2013-09-25' THEN 'pre'
WHEN created_at BETWEEN '2013-09-25' AND'2013-10-25' THEN 'post'
ELSE NULL END AS time_period,
website_session_id,
website_pageview_id
FROM website_pageviews
WHERE created_at BETWEEN '2013-08-25' AND'2013-10-25'
AND pageview_url = '/cart'
;
-- +-------------+--------------------+---------------------+
-- | time_period | website_session_id | website_pageview_id |
-- +-------------+--------------------+---------------------+
-- | pre         |             132797 |              309424 |
-- | pre         |             132799 |              309433 |
-- | post        |             132806 |              309447 |
-- | post        |             132808 |              309457 |

-- step 2: find all pageviews after cart
DROP TABLE IF EXISTS cart_sessions_w_next_page;
CREATE TEMPORARY TABLE  cart_sessions_w_next_page
SELECT cs.time_period,
cs.website_session_id,
MIN(wp.website_pageview_id) AS next_page
FROM cart_sessions cs
JOIN website_pageviews wp ON        -- inner join bc we end up left joining later
wp.website_session_id = cs.website_session_id
AND wp.website_pageview_id > cs.website_pageview_id
GROUP BY 1,2;
-- +-------------+--------------------+-----------+
-- | time_period | website_session_id | next_page |
-- +-------------+--------------------+-----------+
-- | pre         |             132799 |    309434 |
-- | post        |             132806 |    309448 |
-- | post        |             132808 |    309459 |
-- | post        |             132853 |    309556 |
-- | post        |             132861 |    309585 |

-- step 3: find all orders  within cart sessions
DROP TABLE IF EXISTS cart_sessions_w_orders;
CREATE TEMPORARY TABLE cart_sessions_w_orders
SELECT cs.time_period,
cs.website_session_id,
o.order_id,
o.items_purchased,
o.price_usd

FROM cart_sessions cs
JOIN orders o ON                    -- inner join bc we end up left joining later
o.website_session_id = cs.website_session_id;
-- +-------------+--------------------+----------+-----------------+-----------+
-- | time_period | website_session_id | order_id | items_purchased | price_usd |
-- +-------------+--------------------+----------+-----------------+-----------+
-- | pre         |             132797 |     7296 |               1 |     49.99 |
-- | post        |             132808 |     7297 |               1 |     49.99 |
-- | post        |             132853 |     7298 |               1 |     49.99 |
-- | post        |             132861 |     7299 |               1 |     49.99 |
-- | post        |             132876 |     7300 |               2 |    109.98 |

-- step 4: flags
SELECT time_period,
COUNT(website_session_id) AS sessions,
SUM(has_next_page) AS clickthroughs,
SUM(has_next_page)/COUNT(website_session_id) AS CTR_next_page,
SUM(has_order) AS orders_placed,
SUM(items_purchased) AS products_purchased,
SUM(items_purchased)/SUM(has_order) AS AVG_products_per_order,
AVG(price_usd) AS AOV,
SUM(price_usd) AS revenue
FROM(
SELECT cs.time_period,
cs.website_session_id,
CASE WHEN cswnp.next_page IS NULL THEN 0 ELSE 1 END AS has_next_page,
CASE WHEN cswo.order_id IS NULL THEN 0 ELSE 1 END AS has_order,
cswo.items_purchased,
cswo.price_usd
FROM cart_sessions cs
LEFT JOIN cart_sessions_w_next_page cswnp ON cswnp.website_session_id = cs.website_session_id
LEFT JOIN cart_sessions_w_orders cswo ON cswo.website_session_id = cs.website_session_id
) AS temp
GROUP BY 1;

-- OUTPUT:
-- +-------------+----------+---------------+---------------+---------------+--------------------+------------------------+-----------+----------+
-- | time_period | sessions | clickthroughs | CTR_next_page | orders_placed | products_purchased | AVG_products_per_order | AOV       | revenue  |
-- +-------------+----------+---------------+---------------+---------------+--------------------+------------------------+-----------+----------+
-- | pre         |     1830 |          1229 |        0.6716 |           652 |                652 |                 1.0000 | 51.416380 | 33523.48 |
-- | post        |     1975 |          1351 |        0.6841 |           671 |                701 |                 1.0447 | 54.251848 | 36402.99 |
-- +-------------+----------+---------------+---------------+---------------+--------------------+------------------------+-----------+----------+
-- --------------------------------------------------------------------------------------------
-- SUBJECT 6: Recent Product Launch 
--                                                 January 12, 2014
-- Hi there,

-- On December 12, 2013, we launched a third product targeting the birthday gift market (Birthday Bear)

-- Could you please run a PRE-POST ANALYSIS COMPARING THE MONTH BEFORE VS MONTH AFTER, in terms
-- of SESSION-TO-ORDER CONVERSION RATE, AOV, PRODUCTS PER ORDER, AND REVENUE PER SESSION?

-- Thanks,
-- Cindy
-- --------------------------------------------------------------------------------------------

-- step 1: find pre and post sessions
DROP TABLE IF EXISTS pre_post_sessions;
CREATE TEMPORARY TABLE pre_post_sessions
SELECT website_session_id,
created_at,
CASE WHEN created_at BETWEEN '2013-11-12' AND '2013-12-12' THEN 'pre' 
WHEN created_at BETWEEN '2013-12-12' AND '2013-01-12' THEN 'post'
    ELSE NULL END AS time_period
FROM website_sessions
WHERE created_at BETWEEN '2013-11-12' AND '2014-01-12';

-- step 2: create sessions with order table
DROP TABLE IF EXISTS sessions_w_orders;
CREATE TEMPORARY TABLE sessions_w_orders
SELECT pps.time_period,
pps.website_session_id,
o.order_id,
o.items_purchased,
o.price_usd
FROM pre_post_sessions pps
LEFT JOIN orders o ON           
o.website_session_id = pps.website_session_id;
-- +-------------+--------------------+----------+-----------------+-----------+
-- | time_period | website_session_id | order_id | items_purchased | price_usd |
-- +-------------+--------------------+----------+-----------------+-----------+
-- | pre         |             149216 |     8356 |               1 |     49.99 |
-- | pre         |             149217 |     NULL |            NULL |      NULL |
-- | pre         |             149218 |     NULL |            NULL |      NULL |
-- | pre         |             149219 |     NULL |            NULL |      NULL |
-- | pre         |             149220 |     8357 |               1 |     49.99 |

-- step 3 aggregate
SELECT time_period,
COUNT(website_session_id) AS sessions,
COUNT(order_id) AS orders,
COUNT(order_id)/COUNT(website_session_id) AS session_to_order,
AVG(price_usd) AS AOV,
SUM(items_purchased)/COUNT(order_id) AS products_per_order,
SUM(price_usd)/COUNT(website_session_id) AS rev_per_session
FROM sessions_w_orders
GROUP BY 1;

-- OUTPUT:
-- +-------------+----------+--------+------------------+-----------+--------------------+-----------------+
-- | time_period | sessions | orders | session_to_order | AOV       | products_per_order | rev_per_session |
-- +-------------+----------+--------+------------------+-----------+--------------------+-----------------+
-- | pre         |    17343 |   1055 |           0.0608 | 54.226502 |             1.0464 |        3.298677 |
-- | NULL        |    13383 |    940 |           0.0702 | 56.931319 |             1.1234 |        3.998763 |
-- +-------------+----------+--------+------------------+-----------+--------------------+-----------------+

-- Business Concept: Product Refund Analysis
-- Analyzing product refund rates is about CONTROLLING FOR WUALITY AND UNDESTANDING WHERE YOU MIGHT HAVE 
-- PROBLEMS TO ADDRESS
-- --------------------------------------------------------------------------------------------
-- SUBJECT 7: Quick Issues & Refunds 
--                                                 October 14, 2014
-- Hi there,

-- Our Mr. Fuzzy supplier had some quality issues which weren't corrected until September 2013.
-- Then they had a major problem where the bears' arms were falling off in Aug/Sep 2014. 
-- As a result, we replaced them witha new supplier on September 16, 2014

-- Can you please pull MONTHLY PRODUCT REFUND RATES, BY PRODUCT, AND CONFIRM OUR QUALITY ISSUES
-- ARE NOW FIXED?

-- Thanks,
-- Cindy
-- --------------------------------------------------------------------------------------------

-- how many products are there
USE mavenfuzzyfactory;
SELECT primary_product_id
FROM orders
group by 1;
-- +--------------------+
-- | primary_product_id |
-- +--------------------+
-- |                  1 |
-- |                  2 |
-- |                  3 |
-- |                  4 |
-- +--------------------+

SELECT MIN(YEAR(o.created_at)) AS start_year,
 MIN(MONTH(o.created_at)) AS start_year,
COUNT(CASE WHEN o.product_id = 1 THEN o.order_id ELSE NULL END)
    AS p1_orders,
COUNT(DISTINCT CASE WHEN o.product_id = 1 THEN oir.order_item_id ELSE NULL END)/COUNT(CASE WHEN o.product_id = 1 THEN o.order_id ELSE NULL END)
    AS p1_refund_rate,
COUNT(CASE WHEN o.product_id = 2 THEN o.order_id ELSE NULL END)
    AS p2_orders,
COUNT(CASE WHEN o.product_id = 2 THEN oir.order_item_id ELSE NULL END)/COUNT(CASE WHEN o.product_id = 2 THEN o.order_id ELSE NULL END)
    AS p2_refund_rate,
COUNT(CASE WHEN o.product_id = 3 THEN o.order_id ELSE NULL END)
    AS p3_orders,
COUNT(CASE WHEN o.product_id = 3 THEN oir.order_item_id ELSE NULL END)/COUNT(CASE WHEN o.product_id = 3 THEN o.order_id ELSE NULL END)
    AS p3_refund_rate,
COUNT(CASE WHEN o.product_id = 4 THEN o.order_id ELSE NULL END)
    AS p4_orders,
COUNT(CASE WHEN o.product_id = 4 THEN oir.order_item_id ELSE NULL END)/COUNT(CASE WHEN o.product_id = 4 THEN o.order_id ELSE NULL END)
    AS p4_refund_rate
FROM order_items o
LEFT JOIN order_item_refunds oir ON
o.order_id = oir.order_id
WHERE o.created_at < '2014-10-15'
GROUP BY YEAR(o.created_at), MONTH(o.created_at);

-- OUTPUT:
-- +------------+------------+-----------+----------------+-----------+----------------+-----------+----------------+-----------+----------------+
-- | start_year | start_year | p1_orders | p1_refund_rate | p2_orders | p2_refund_rate | p3_orders | p3_refund_rate | p4_orders | p4_refund_rate |
-- +------------+------------+-----------+----------------+-----------+----------------+-----------+----------------+-----------+----------------+
-- |       2012 |          3 |        60 |         0.0167 |         0 |           NULL |         0 |           NULL |         0 |           NULL |
-- |       2012 |          4 |        99 |         0.0505 |         0 |           NULL |         0 |           NULL |         0 |           NULL |
-- |       2012 |          5 |       108 |         0.0370 |         0 |           NULL |         0 |           NULL |         0 |           NULL |
-- |       2012 |          6 |       140 |         0.0571 |         0 |           NULL |         0 |           NULL |         0 |           NULL |
-- |       2012 |          7 |       169 |         0.0828 |         0 |           NULL |         0 |           NULL |         0 |           NULL |
-- |       2012 |          8 |       228 |         0.0746 |         0 |           NULL |         0 |           NULL |         0 |           NULL |
-- |       2012 |          9 |       287 |         0.0906 |         0 |           NULL |         0 |           NULL |         0 |           NULL |
-- |       2012 |         10 |       371 |         0.0728 |         0 |           NULL |         0 |           NULL |         0 |           NULL |
-- |       2012 |         11 |       618 |         0.0744 |         0 |           NULL |         0 |           NULL |         0 |           NULL |
-- |       2012 |         12 |       506 |         0.0593 |         0 |           NULL |         0 |           NULL |         0 |           NULL |
-- |       2013 |          1 |       343 |         0.0496 |        47 |         0.0213 |         0 |           NULL |         0 |           NULL |
-- |       2013 |          2 |       336 |         0.0714 |       162 |         0.0123 |         0 |           NULL |         0 |           NULL |
-- |       2013 |          3 |       320 |         0.0563 |        65 |         0.0462 |         0 |           NULL |         0 |           NULL |
-- |       2013 |          4 |       459 |         0.0414 |        94 |         0.0106 |         0 |           NULL |         0 |           NULL |
-- |       2013 |          5 |       489 |         0.0634 |        82 |         0.0244 |         0 |           NULL |         0 |           NULL |
-- |       2013 |          6 |       503 |         0.0775 |        90 |         0.0556 |         0 |           NULL |         0 |           NULL |
-- |       2013 |          7 |       509 |         0.0727 |        95 |         0.0316 |         0 |           NULL |         0 |           NULL |
-- |       2013 |          8 |       510 |         0.0549 |        98 |         0.0102 |         0 |           NULL |         0 |           NULL |
-- |       2013 |          9 |       537 |         0.0428 |        98 |         0.0102 |         0 |           NULL |         0 |           NULL |
-- |       2013 |         10 |       603 |         0.0282 |       135 |         0.0296 |         0 |           NULL |         0 |           NULL |
-- |       2013 |         11 |       724 |         0.0359 |       174 |         0.0287 |         0 |           NULL |         0 |           NULL |
-- |       2013 |         12 |       819 |         0.0281 |       184 |         0.0380 |       139 |         0.0791 |         0 |           NULL |
-- |       2014 |          1 |       728 |         0.0481 |       183 |         0.0437 |       200 |         0.0900 |         0 |           NULL |
-- |       2014 |          2 |       584 |         0.0479 |       351 |         0.0256 |       211 |         0.0806 |       202 |         0.0495 |
-- |       2014 |          3 |       785 |         0.0369 |       193 |         0.0259 |       244 |         0.0820 |       205 |         0.0341 |
-- |       2014 |          4 |       917 |         0.0436 |       214 |         0.0374 |       267 |         0.0787 |       259 |         0.0541 |
-- |       2014 |          5 |      1030 |         0.0398 |       246 |         0.0244 |       299 |         0.0669 |       298 |         0.0369 |
-- |       2014 |          6 |       893 |         0.0717 |       245 |         0.0449 |       288 |         0.0903 |       249 |         0.1044 |
-- |       2014 |          7 |       961 |         0.0541 |       244 |         0.0615 |       276 |         0.0580 |       264 |         0.0341 |
-- |       2014 |          8 |       959 |         0.1470 |       238 |         0.0546 |       294 |         0.1088 |       303 |         0.1056 |
-- |       2014 |          9 |      1057 |         0.1447 |       251 |         0.0717 |       318 |         0.1195 |       327 |         0.1131 |
-- |       2014 |         10 |       513 |         0.0390 |       135 |         0.0148 |       165 |         0.0909 |       155 |         0.0581 |
-- +------------+------------+-----------+----------------+-----------+----------------+-----------+----------------+-----------+----------------+