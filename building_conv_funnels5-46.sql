-- **THIS IS NOT MY ORIGINAL DATA, used solutions for assistance as needed
-- ** UDEMY IS RESPONSIBLE

-- analyzing bounce rates for a start-up e-commerce business
-- this data represents multiple user sessions showing the path of webpages
-- they go through before purchasing a product from the business.  some users
-- get as far as the homepage but dont seek further exploration within the website.
-- the first page the user views are called "landing pages" and if they only
-- view one page during their session, this is also called a bounce page


-- ---------------------------------------------------
-- EMAIL:
--                                        September 5, 2012
-- Hi there!

-- I'd like to understand where we lose our gsearch visitors between the new /lander1 
-- page and placing an order. Can you build us a full conversion funnel, analyzing how
-- customers make it to each step?

-- Start with /lander-1 and build the funnel all the way to our thank you page.  Please
-- use data since August 5th.

-- Thanks!
-- -Morgan


USE mavenfuzzyfactory;

DROP TABLE IF EXISTS made_it2_progress;
CREATE TEMPORARY TABLE made_it2_progress 
SELECT website_session_id,   -- grouping each session and showing the progress reached using 1 or 0
MAX(lander1_flag) AS made_it2_lander,
MAX(products_flag) AS made_it2_products,
MAx(og_mr_fuzzy_flag) AS made_it2_og_mr_fuzzy,
MAX(cart_flag) AS made_it2_cart,
MAX(shipping_flag) AS made_it2_shipping,
MAX(billing_flag) AS made_it2_billing,
MAX(ty_flag) AS made_it2_ty
FROM
(SELECT ws.website_session_id,  -- creating sub query to flag each url for each session
    wp.pageview_url,
    wp.created_at,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander1_flag,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_flag,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS og_mr_fuzzy_flag,
    CASE WHEN pageview_url =  '/cart' THEN 1 ELSE 0 END AS cart_flag,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_flag,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_flag,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS ty_flag
FROM website_pageviews wp
JOIN website_sessions ws ON  -- using join to make constraints
ws.website_session_id = wp.website_session_id  
WHERE wp.created_at BETWEEN '2012-08-05' -- data constraints based off email
    AND '2012-09-05'
    AND ws.utm_source = 'gsearch'
    AND ws.utm_campaign = 'nonbrand'
ORDER BY ws.website_session_id, wp.created_at) AS sub_query
GROUP BY 1;

-- PART 1:
-- this query will analyze how many customers make it to each step
SELECT 
COUNT(DISTINCT website_session_id)
    AS total_sessions,
COUNT(CASE WHEN made_it2_lander=1 THEN made_it2_lander ELSE NULL END)
    AS total_lander_page,
COUNT( CASE WHEN made_it2_products=1 THEN made_it2_products ELSE NULL END)
    AS total_product_page,
COUNT(CASE WHEN made_it2_og_mr_fuzzy=1 THEN made_it2_og_mr_fuzzy ELSE NULL END)
    AS total_og_mrf_page,
COUNT(CASE WHEN made_it2_cart=1 THEN made_it2_cart ELSE NULL END)
    AS total_cart_page,
COUNT(CASE WHEN made_it2_shipping=1 THEN made_it2_shipping ELSE NULL END)
    AS total_shipping_page,
COUNT(CASE WHEN made_it2_ty=1 THEN made_it2_ty ELSE NULL END)
    AS total_ty_page
FROM
made_it2_progress;

-- PART 2:
-- this query analyzes the click rates going into eachstep
SELECT 
COUNT( CASE WHEN made_it2_products=1 THEN made_it2_products ELSE NULL END)/COUNT(DISTINCT website_session_id)
    AS product_clk_rate,
COUNT(CASE WHEN made_it2_og_mr_fuzzy=1 THEN made_it2_og_mr_fuzzy ELSE NULL END)/COUNT( CASE WHEN made_it2_products=1 THEN made_it2_products ELSE NULL END)
    AS og_mrf_clk_rate,
COUNT(CASE WHEN made_it2_cart=1 THEN made_it2_cart ELSE NULL END)/COUNT(CASE WHEN made_it2_og_mr_fuzzy=1 THEN made_it2_og_mr_fuzzy ELSE NULL END)
    AS cart_clk_rate,
COUNT(CASE WHEN made_it2_shipping=1 THEN made_it2_shipping ELSE NULL END)/COUNT(CASE WHEN made_it2_cart=1 THEN made_it2_cart ELSE NULL END)
    AS shipping_clk_rate,
COUNT(CASE WHEN made_it2_ty=1 THEN made_it2_ty ELSE NULL END)/COUNT(CASE WHEN made_it2_shipping=1 THEN made_it2_shipping ELSE NULL END)
    AS ty_clk_rate
FROM made_it2_progress;