-- **THIS IS NOT MY ORIGINAL DATA, used solutions for assistance as needed
-- ** UDEMY IS RESPONSIBLE
-- COURSE: Advanced SQL: MySQL Data Analysis & Business Intelligence
-- by Maven Analytics, John Pauler

-- --------------------------------------------------------------------------------------------
-- SUBJECT 1: Understanding Seasonality
--                                                 January 02, 2013
-- Hi there,

-- 2012 was a great year for us. As we continue to grow, we should TAKE A LOOK AT 2012'S
-- MONTHLY AND WEEKLY VOLUME PATTERNS, to see if we can find any seasonal trends we should plan
-- for in 2023

-- Thanks,
-- Cindy
-- --------------------------------------------------------------------------------------------




-- by month
USE mavenfuzzyfactory;
SELECT MIN(DATE(ws.created_at)) AS start_date,
COUNT(ws.website_session_id) AS sessions,
COUNT(o.order_id) AS orders
FROM website_sessions ws
LEFT JOIN orders o ON
o.website_session_id = ws.website_session_id
WHERE YEAR(ws.created_at) = '2012'
GROUP BY MONTH(DATE(ws.created_at));
--          ^change --> WEEK(DATE(ws.created_at)) for weekly analysis 

-- OUTPUT:
-- +------------+----------+--------+
-- | start_date | sessions | orders |
-- +------------+----------+--------+
-- | 2012-03-19 |     1879 |     60 |
-- | 2012-04-01 |     3734 |     99 |
-- | 2012-05-01 |     3736 |    108 |
-- | 2012-06-01 |     3963 |    140 |
-- | 2012-07-01 |     4249 |    169 |
-- | 2012-08-01 |     6097 |    228 |
-- | 2012-09-01 |     6546 |    287 |
-- | 2012-10-01 |     8183 |    371 |
-- | 2012-11-01 |    14011 |    618 |
-- | 2012-12-01 |    10072 |    506 |
-- +------------+----------+--------+
-- --------------------------------------------------------------------------------------------
-- SUBJECT 2: Understanding Seasonality
--                                                 January 02, 2013
-- Hi there,

-- We're considering adding live chat support to the website to improve our customer experience.  
-- Could you analyze the AVERAGE WEBSITE SESSION VOLUME, BY HOUR OF DAY AND BY DAY WEEK, so that
-- we can staff appropriately?

-- Lets avoid the holiday time period and use a date range of SEPT 15- NOV 15 2012

-- Thanks,
-- Cindy
-- --------------------------------------------------------------------------------------------


SELECT hour,
ROUND(AVG(CASE WHEN weekday = 0 THEN total_sessions ELSE NULL END),1)AS mon,
ROUND(AVG(CASE WHEN weekday = 1 THEN total_sessions ELSE NULL END),1) AS tue,
ROUND(AVG(CASE WHEN weekday = 2 THEN total_sessions ELSE NULL END),1) AS wed,
ROUND(AVG(CASE WHEN weekday = 3 THEN total_sessions ELSE NULL END),1) AS thu,
ROUND(AVG(CASE WHEN weekday = 4 THEN total_sessions ELSE NULL END),1) AS fri,
ROUND(AVG(CASE WHEN weekday = 5 THEN total_sessions ELSE NULL END),1) AS sat,
ROUND(AVG(CASE WHEN weekday = 6 THEN total_sessions ELSE NULL END),1) AS sun
FROM
(SELECT 
DATE(created_at) AS date,   
HOUR(created_at) AS hour,
WEEKDAY(created_at) AS weekday,
COUNT(DISTINCT website_session_id) AS total_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3) AS temp
GROUP BY 1;

-- OUTPUT:
-- +------+------+------+------+------+------+------+------+
-- | hour | mon  | tue  | wed  | thu  | fri  | sat  | sun  |
-- +------+------+------+------+------+------+------+------+
-- |    0 |  8.7 |  7.7 |  6.3 |  7.4 |  6.8 |  5.0 |  5.0 |
-- |    1 |  6.6 |  6.7 |  5.3 |  4.9 |  7.1 |  5.0 |  3.0 |
-- |    2 |  6.1 |  4.4 |  4.4 |  6.1 |  4.6 |  3.7 |  3.0 |
-- |    3 |  5.7 |  4.0 |  4.7 |  4.6 |  3.6 |  3.9 |  3.4 |
-- |    4 |  5.9 |  6.3 |  6.0 |  4.0 |  6.1 |  2.8 |  2.4 |
-- |    5 |  5.0 |  5.4 |  5.1 |  5.4 |  4.6 |  4.3 |  3.9 |
-- |    6 |  5.4 |  5.6 |  4.8 |  6.0 |  6.8 |  4.0 |  2.6 |
-- |    7 |  7.3 |  7.8 |  7.4 | 10.6 |  7.0 |  5.7 |  4.8 |
-- |    8 | 12.3 | 12.2 | 13.0 | 16.5 | 10.5 |  4.3 |  4.1 |
-- |    9 | 17.6 | 15.7 | 19.6 | 19.3 | 17.5 |  7.6 |  6.0 |
-- |   10 | 18.4 | 17.7 | 21.0 | 18.4 | 19.0 |  8.3 |  6.3 |
-- |   11 | 18.0 | 19.1 | 24.9 | 21.6 | 20.9 |  7.2 |  7.7 |
-- |   12 | 21.1 | 23.3 | 22.8 | 24.1 | 19.0 |  8.6 |  6.1 |
-- |   13 | 17.8 | 23.0 | 20.8 | 20.6 | 21.6 |  8.1 |  8.4 |
-- |   14 | 17.9 | 21.6 | 22.3 | 18.5 | 19.5 |  8.7 |  6.7 |
-- |   15 | 21.6 | 17.1 | 25.3 | 23.5 | 21.3 |  6.9 |  7.1 |
-- |   17 | 19.4 | 15.9 | 20.2 | 19.8 | 12.9 |  6.4 |  7.6 |
-- |   18 | 12.7 | 15.0 | 14.8 | 15.3 | 10.9 |  5.3 |  6.8 |
-- |   19 | 12.4 | 14.1 | 13.3 | 11.6 | 14.3 |  7.1 |  6.4 |
-- |   20 | 12.1 | 12.4 | 14.2 | 10.6 | 10.3 |  5.7 |  8.4 |
-- |   21 |  9.1 | 12.6 | 11.4 |  9.4 |  7.3 |  5.7 | 10.2 |
-- |   22 |  9.1 | 10.0 |  9.8 | 12.1 |  6.0 |  5.7 | 10.2 |
-- |   23 |  8.8 |  8.6 |  9.6 | 10.6 |  7.6 |  5.3 |  8.3 |
-- |   16 | 21.1 | 23.7 | 23.7 | 19.6 | 20.9 |  7.6 |  6.6 |
-- +------+------+------+------+------+------+------+------+