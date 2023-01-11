-- **THIS IS NOT MY ORIGINAL DATA, used solutions for assistance as needed
-- ** UDEMY IS RESPONSIBLE
-- COURSE: Advanced SQL: MySQL Data Analysis & Business Intelligence
-- by Maven Analytics, John Pauler

-- analyzing bounce rates for a start-up e-commerce business
-- this data represents multiple user sessions showing the path of webpages
-- they go through before purchasing a product from the business.  some users
-- get as far as the homepage but dont seek further exploration within the website.
-- the first page the user views are called "landing pages" and if they only
-- view one page during their session, this is also called a bounce page

-- PSEUDO: 
-- my task was analyze ladning page trend analysis by week.
-- find: bounce rate, home landing page (LP) sessions, lander-1 LP sessions by WEEK
-- first, find the first page view and total page view count for each session 
-- then, turn pageview to landing page and add time
-- then, turn time to weekly interval in order to find weekly bounce rate, weekly home sessions, weekly lander sessions


-- ------------------------------------------------------------------------
-- EMAIL:
-- SUBJECT: Help Analyzing Conversion Funnels
--                                                              September 5, 2012
-- Hi there!

-- Could you pull the volume of paid search nonbrand traffic landing on /home and /lander-1,
-- trended weekly since June 1st?  I want to confirm the traffic is all routed correctly.

-- Could you also pull our overall paid search bounce rate trended weekly? I want to make sure
-- the lander change has improved the overall picture.

-- Thanks!
-- -Morgan
----------------------------------------------------------------------------

-- SOLUTION:

USE mavenfuzzyfactory;
DROP TABLE IF EXISTS temp_table;
CREATE TEMPORARY TABLE temp_table  -- finding first pageview_id of each session
SELECT wp.website_session_id, 
MIN(wp.website_pageview_id) AS min_pv, 
COUNT(wp.website_pageview_id) AS count  -- count of all pageviews within each session
FROM website_pageviews wp
JOIN website_sessions ws ON -- join in order to add filters
ws.website_session_id = wp.website_session_id
AND ws.created_at BETWEEN '2012-06-01' AND '2012-08-31'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY 1; --  grouping to 

-- +--------------------+--------+-------+
-- | website_session_id | min_pv | count |
-- +--------------------+--------+-------+
-- |               9350 |  18598 |     3 |
-- |               9351 |  18600 |     3 |
-- |               9352 |  18601 |     4 |
-- |               9354 |  18611 |     1 |
-- |               9356 |  18616 |     6 |
-- |               9357 |  18622 |     1 |
-- |               9358 |  18623 |     3 |
-- TO BE CONTINUED...

DROP TABLE IF EXISTS temp_table_w_time;
CREATE TEMPORARY TABLE temp_table_w_time -- temp table with landing_page and time added
SELECT t.website_session_id, 
t.min_pv,
t.count,
w.pageview_url AS landing_page, -- changing page view to landing page
w.created_at -- adding time
FROM temp_table t
JOIN website_pageviews w ON 
w.website_pageview_id = t.min_pv
;

DROP TABLE IF EXISTS weekly_bounce_analysis;
CREATE TEMPORARY TABLE weekly_bounce_analysis; -- bounce analysis by week
SELECT MIN(DATE(tt.created_at))  -- showing start date of each week
	AS week_start_date,
-- COUNT(count), -- counting total sessions
-- COUNT(CASE WHEN count = 1 THEN count ELSE NULL END) -- counting total bounced sessions
COUNT(CASE WHEN count = 1 THEN count ELSE NULL END)/COUNT(count)
	AS bounce_rate,  -- calculating bounced rate,
COUNT(CASE WHEN tt.landing_page = '/home' THEN tt.landing_page ELSE NULL END) 
	AS home_sessions,  -- counting total home landing pages
COUNT(CASE WHEN tt.landing_page = '/lander-1' THEN tt.landing_page ELSE NULL END) 
	AS lander_sessions  -- counting total lander-1 landing pages
FROM temp_table_w_time tt 
GROUP BY WEEK(tt.created_at) -- need to group in order to perform aggregate analysis by weekly
;

-- OUTPUT:
-- +-----------------+-------------+---------------+-----------------+
-- | week_start_date | bounce_rate | home_sessions | lander_sessions |
-- +-----------------+-------------+---------------+-----------------+
-- | 2012-06-01      |      0.6057 |           175 |               0 |
-- | 2012-06-03      |      0.5871 |           792 |               0 |
-- | 2012-06-10      |      0.6160 |           875 |               0 |
-- | 2012-06-17      |      0.5582 |           492 |             350 |
-- | 2012-06-24      |      0.5828 |           369 |             386 |
-- | 2012-07-01      |      0.5821 |           392 |             388 |
-- | 2012-07-08      |      0.5668 |           390 |             411 |
-- | 2012-07-15      |      0.5424 |           429 |             421 |
-- | 2012-07-22      |      0.5138 |           402 |             394 |
-- | 2012-07-29      |      0.4971 |            33 |             995 |
-- | 2012-08-05      |      0.5382 |             0 |            1087 |
-- | 2012-08-12      |      0.5140 |             0 |             998 |
-- | 2012-08-19      |      0.5010 |             0 |            1012 |
-- | 2012-08-26      |      0.5378 |             0 |             833 |
-- +-----------------+-------------+---------------+-----------------+

