-- **THIS IS NOT MY ORIGINAL DATA, used solutions for assistance as needed
-- ** UDEMY IS RESPONSIBLE

-- analyzing bounce rates for a start-up e-commerce business
-- this data represents multiple user sessions showing the path of webpages
-- they go through before purchasing a product from the business.  some users
-- get as far as the homepage but dont seek further exploration within the website.
-- the first page the user views are called "landing pages" and if they only
-- view one page during their session, this is also called a bounce page

-- my task was analyze ladning page trend analysis by week.
-- find: bounce rate, home landing page (LP) sessions, lander-1 LP sessions by WEEK
-- first, find the first page view and total page view count for each session 
-- then, turn pageview to landing page and add time
-- then, turn time to weekly interval in order to find weekly bounce rate, weekly home sessions, weekly lander sessions



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

