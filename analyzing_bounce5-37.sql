-- **THIS IS NOT MY ORIGINAL DATA, USED SOLUTIONS WITH ASSISTANCE AS NEEDED
-- ** UDEMY IS RESPONSIBLE
-- COURSE: Advanced SQL: MySQL Data Analysis & Business Intelligence
-- by Maven Analytics, John Pauler

-- analyzing bounce rates for a start-up e-commerce business
-- this data represents multiple user sessions showing the path of webpages
-- they go through before purchasing a product from the business.  some users
-- get as far as the homepage but dont seek further exploration within the website.
-- the first page the user views are called "landing pages" and if they only
-- view one page during their session, this is also called a bounce page

-- my task was analyze page performance by creating a multi-step query in order 
-- to identify each landing page and total amount of sessions, bounced_sessions, and bounced rate for each session
-- first, find the first page view for each session
-- then, turn that into landing page by self join
-- then, find the count of each webpage views during each session
-- then, narrow it down to bounced sessions
-- finally, identify bounce rate

USE mavenfuzzyfactory;

DROP TABLE IF EXISTS temp_table;
CREATE TEMPORARY TABLE temp_table  -- finding first pageview_id of each session
SELECT website_session_id, 
MIN(website_pageview_id) AS min_pv
FROM website_pageviews
WHERE created_at BETWEEN '2014-01-01' AND '2014-02-01'  -- completely arbitrary
GROUP BY 1; --  grouping to 

DROP TABLE IF EXISTS temp_table2;
CREATE TEMPORARY TABLE temp_table2 -- turing pv to url to see landing page of each session 
SELECT t.website_session_id, 
w.pageview_url AS landing_page
FROM temp_table t
JOIN website_pageviews w ON 
w.website_pageview_id = t.min_pv
;

DROP TABLE IF EXISTS bounced_sess_only;
CREATE TEMPORARY TABLE bounced_sess_only -- analyzing if that session had additional page views
SELECT tt.website_session_id, tt.landing_page, -- will group to find count of total pages
COUNT(w.website_pageview_id) AS count -- counting pv_ids associated to grouping
FROM temp_table2 tt 
JOIN website_pageviews w ON
w.website_session_id = tt.website_session_id
GROUP BY 1,2
HAVING count = 1 -- filtering the bounced pages (sessions that have 1 pageview url)
;

DROP TABLE IF EXISTS bounced_or_not;
CREATE TEMPORARY TABLE bounced_or_not
SELECT tt.website_session_id, tt.landing_page,
s.count
FROM temp_table2 tt
LEFT JOIN bounced_sess_only s ON -- left join to show null values (which represent nonbounced sessions)
s.website_session_id = tt.website_session_id
ORDER BY tt.website_session_id; -- will order it how the order is in temp_table2 (easier to show null values)

SELECT bb.landing_page, 
COUNT(bb.website_session_id) AS sessions,
COUNT(b.count) AS bounced_sessions,
COUNT(b.count)/COUNT(bb.website_session_id) AS bounced_rate
FROM bounced_or_not bb
LEFT JOIN bounced_sess_only b ON
b.website_session_id = bb.website_session_id
GROUP BY 1
ORDER BY 1;

-- OUTPUT:
-- +--------------+----------+------------------+--------------+
-- | landing_page | sessions | bounced_sessions | bounced_rate |
-- +--------------+----------+------------------+--------------+
-- | /home        |     4093 |             1575 |       0.3848 |
-- | /lander-2    |     6500 |             2855 |       0.4392 |
-- | /lander-3    |     4232 |             2606 |       0.6158 |
-- | /products    |        1 |                0 |       0.0000 |
-- +--------------+----------+------------------+--------------+
