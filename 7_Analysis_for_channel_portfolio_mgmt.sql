-- **THIS IS NOT MY ORIGINAL DATA, used solutions for assistance as needed
-- ** UDEMY IS RESPONSIBLE
-- COURSE: Advanced SQL: MySQL Data Analysis & Business Intelligence
-- by Maven Analytics, John Pauler

-- --------------------------------------------------------------------------------------------
-- SUBJECT 1: Expanded Channel Portfolio
--                                                 November 29, 2012
-- Hi there,

-- With gsearch doing well and the site performing better, WE LAUNCHED A SECOND PAID SEARCH
-- CHANNEL, BSEARCH, around August 22.

-- Can you pull WEEKLY TRENDED SESSION VOLUME since then and COMPARE TO GSEARCH NONBRAND so I
-- can get a sense for how important this will be for the business?

-- Thanks,
-- Tom
-- --------------------------------------------------------------------------------------------

SELECT MIN(DATE(ws.created_at)) AS week_start_date,
COUNT(ws.website_session_id) AS total_sessions,
COUNT(CASE WHEN utm_source = 'gsearch' THEN ws.website_session_id ELSE NULL END)
    AS gsearch_sessions,
COUNT(CASE WHEN utm_source = 'bsearch' THEN ws.website_session_id ELSE NULL END)
    AS bsearch_sessions
FROM website_sessions ws
WHERE ws.created_at BETWEEN '2012-08-22' AND '2012-11-29'
    AND utm_campaign = 'nonbrand'
GROUP BY WEEK(DATE(ws.created_at));

-- -- OUTPUT:
-- +-----------------+----------------+------------------+------------------+
-- | weel_start_date | total_sessions | gsearch_sessions | bsearch_sessions |
-- +-----------------+----------------+------------------+------------------+
-- | 2012-08-22      |            787 |              590 |              197 |
-- | 2012-08-26      |           1399 |             1056 |              343 |
-- | 2012-09-02      |           1215 |              925 |              290 |
-- | 2012-09-09      |           1280 |              951 |              329 |
-- | 2012-09-16      |           1516 |             1151 |              365 |
-- | 2012-09-23      |           1371 |             1050 |              321 |
-- | 2012-09-30      |           1315 |              999 |              316 |
-- | 2012-10-07      |           1332 |             1002 |              330 |
-- | 2012-10-14      |           1677 |             1257 |              420 |
-- | 2012-10-21      |           1733 |             1302 |              431 |
-- | 2012-10-28      |           1595 |             1211 |              384 |
-- | 2012-11-04      |           1779 |             1350 |              429 |
-- | 2012-11-11      |           1684 |             1246 |              438 |
-- | 2012-11-18      |           4601 |             3508 |             1093 |
-- | 2012-11-25      |           3060 |             2286 |              774 |
-- +-----------------+----------------+------------------+------------------+


-- ------------------------



-- --------------------------------------------------------------------------------------------
-- SUBJECT 2: Comparing Our Channels
--                                                 November 30, 2012
-- Hi there,

-- I'd like to learn more about the BSEARCH NONBRAND campaign. Could you please pull the PERCENTAGE
-- OF TRAFFIC COMING ON MOBILE, and COMPARE THAT TO GSEARCH?

-- Feel free to dig around and share anything else you find interesting.  AGGREGATE DATA SINCE 
-- AUGUST 22ND is great, no need to show trending at this point.

-- Thanks,
-- Tom
-- --------------------------------------------------------------------------------------------
USE mavenfuzzyfactory;
SELECT 
CASE WHEN utm_source = 'bsearch' THEN 'bsearch' -- just in case there are more utm_sources
    WHEN utm_source = 'gsearch' THEN 'gsearch' 
    ELSE NULL END AS utm_source,
COUNT(ws.website_session_id) 
    AS sessions,
COUNT(CASE WHEN device_type = 'mobile' THEN ws.website_session_id ELSE NULL END)
    AS mobile_sessions,
FORMAT(COUNT(CASE WHEN device_type = 'mobile' THEN ws.website_session_id ELSE NULL END)/COUNT(ws.website_session_id), PERCENT)
    AS pct_mobile_sessions
FROM website_sessions ws
WHERE ws.created_at BETWEEN '2012-08-22' AND '2012-11-30'
    AND utm_campaign = 'nonbrand'
    GROUP BY 1;
 
 -- OUTPUT:
--  +------------+----------+-----------------+---------------------+
-- | utm_source | sessions | mobile_sessions | pct_mobile_sessions |
-- +------------+----------+-----------------+---------------------+
-- | gsearch    |    20073 |            4921 |              0.2452 |
-- | bsearch    |     6522 |             562 |              0.0862 |
-- +------------+----------+-----------------+---------------------+


-- ------------------------

-- --------------------------------------------------------------------------------------------
-- SUBJECT 3: Expanded Channel Portfolio
--                                                 December 1, 2012
-- Hi there,

-- I'm wondering if bsearch nonbrand should have the same bids as gsearch. Could you pull NONBRAND
-- CONVERSION RATES FROM SESSION TO ORDER FOR GSEARCH AND BSEARCH, AND SLICE THE DATA BY DEVICE TYPE?

-- Please analyze data from AUGUST 22 to SEPTEMBER 18; we ran a special pre-holiday campaign for gsearch
-- starting on SEPTEMBER 19TH, so the data after that isn't fair game

-- Thanks,
-- Tom
-- --------------------------------------------------------------------------------------------

SELECT device_type,utm_source,
COUNT(ws.website_session_id) AS sessions,
COUNT(o.order_id) AS orders,
COUNT(o.order_id)/COUNT(ws.website_session_id) AS conv_rate
FROM website_sessions ws
LEFT JOIN orders o ON
o.website_session_id = ws.website_session_id
WHERE ws.created_at BETWEEN '2012-08-22' AND '2012-09-18'
    AND ws.utm_campaign = 'nonbrand'
GROUP BY 1,2
ORDER BY 1,2;

-- OUTPUT:
-- +-------------+------------+----------+--------+-----------+
-- | device_type | utm_source | sessions | orders | conv_rate |
-- +-------------+------------+----------+--------+-----------+
-- | desktop     | bsearch    |     1118 |     43 |    0.0385 |
-- | desktop     | gsearch    |     2850 |    130 |    0.0456 |
-- | mobile      | bsearch    |      125 |      1 |    0.0080 |
-- | mobile      | gsearch    |      962 |     11 |    0.0114 |
-- +-------------+------------+----------+--------+-----------+


-- ------------------------



-- --------------------------------------------------------------------------------------------
-- SUBJECT 4: Impact of Bid Changes
--                                                 December 22, 2012
-- Hi there,

-- Based on your last analysis, we bid down bsearch nonbrand on December 2nd.

-- Can you pull WEEKLY SESSION VOLUME FOR GSEARCH AND BSEARCH NONBRAND, BROKEN DOWN
-- BY DEVICE, SINCE NOVEMBER 4TH?

-- if you can INCLUDE A COMPARISON METRIC TO SHOW BSEARCH AS A PERCENT OF GSEARCH
-- for each device, that would be great too.

-- Thanks,
-- Tom
-- --------------------------------------------------------------------------------------------

SELECT MIN(DATE(created_at)) AS start_date,
COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END)
    AS gsearch_mobile,
COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END)
    AS bsearch_mobile,
COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END)
    AS b_pct_of_p_mobile,
COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END)
    AS gsearch_desktop,
COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END)
    AS bsearch_desktop,
COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END)
    AS b_pct_of_p_desktop
FROM website_sessions 
WHERE created_at BETWEEN '2012-11-04' AND '2012-12-22'
    AND utm_campaign = 'nonbrand'
GROUP BY WEEK(DATE(created_at));

-- OUTPUT:
-- +------------+----------------+----------------+-------------------+-----------------+-----------------+--------------------+
-- | start_date | gsearch_mobile | bsearch_mobile | b_pct_of_p_mobile | gsearch_desktop | bsearch_desktop | b_pct_of_p_desktop |
-- +------------+----------------+----------------+-------------------+-----------------+-----------------+--------------------+
-- | 2012-11-04 |            323 |             29 |            0.0898 |            1027 |             400 |             0.3895 |
-- | 2012-11-11 |            290 |             37 |            0.1276 |             956 |             401 |             0.4195 |
-- | 2012-11-18 |            853 |             85 |            0.0996 |            2655 |            1008 |             0.3797 |
-- | 2012-11-25 |            692 |             62 |            0.0896 |            2058 |             843 |             0.4096 |
-- | 2012-12-02 |            396 |             31 |            0.0783 |            1326 |             517 |             0.3899 |
-- | 2012-12-09 |            424 |             46 |            0.1085 |            1277 |             293 |             0.2294 |
-- | 2012-12-16 |            376 |             41 |            0.1090 |            1270 |             348 |             0.2740 |
-- +------------+----------------+----------------+-------------------+-----------------+-----------------+--------------------+


-- ------------------------



-- --------------------------------------------------------------------------------------------
-- SUBJECT 5: Site traffic breakdown
--                                                 December 23, 2012
-- Hi there,

-- `A potential investor is asking if we're building any momentum with our brand or if we'll
-- need to keep relying on paid traffic.

-- could you PULL ORGANIC SEARCH, DIRECT TYPE IN, AND PAID BRAND SEARCH SESSIONS BY MONTH,
-- and show those sessions as a % OF PAID SEARCH NONBRAND?

-- -Cindy
-- --------------------------------------------------------------------------------------------


SELECT MIN(DATE(created_at)) AS start_date,
COUNT(CASE WHEN source1 = 'nonbrand' THEN website_session_id ELSE NULL END) 
    AS nonbrand,
COUNT(CASE WHEN source1 = 'brand' THEN website_session_id ELSE NULL END) 
    AS brand,
COUNT(CASE WHEN source1 = 'brand' THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN source1 = 'nonbrand' THEN website_session_id ELSE NULL END) 
    AS brand_to_nonbrand_pct,
COUNT(CASE WHEN source1 = 'direct_type_in' THEN website_session_id ELSE NULL END) 
    AS direct,
COUNT(CASE WHEN source1 = 'direct_type_in' THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN source1 = 'nonbrand' THEN website_session_id ELSE NULL END)
    AS direct_to_nonbrand_pct,
COUNT(CASE WHEN source1 = 'organic_gsearch' OR source1 = 'organic_bsearch' THEN website_session_id ELSE NULL END) 
    AS organic,
COUNT(CASE WHEN source1 = 'organic_gsearch' OR source1 = 'organic_bsearch' THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN source1 = 'nonbrand' THEN website_session_id ELSE NULL END)
    AS organic_to_nonbrand_pct

FROM
(SELECT *,
CASE WHEN http_referer IS NULL THEN 'direct_type_in'
    WHEN http_referer = 'https://www.gsearch.com'AND utm_source IS NULL THEN 'organic_gsearch'
    WHEN http_referer = 'https://www.bsearch.com' AND utm_source IS NULL THEN 'organic_bsearch'
    WHEN utm_campaign = 'brand' THEN 'brand'
    WHEN utm_campaign = 'nonbrand' THEN 'nonbrand' ELSE NULL 
    END AS source1
FROM website_sessions
WHERE created_at < '2012-12-23') AS temp
GROUP BY MONTH(DATE(created_at));

-- -- OUTPUT:
-- +------------+----------+-------+-----------------------+--------+------------------------+---------+-------------------------+
-- | start_date | nonbrand | brand | brand_to_nonbrand_pct | direct | direct_to_nonbrand_pct | organic | organic_to_nonbrand_pct |
-- +------------+----------+-------+-----------------------+--------+------------------------+---------+-------------------------+
-- | 2012-03-19 |     1852 |    10 |                0.0054 |      9 |                 0.0049 |       8 |                  0.0043 |
-- | 2012-04-01 |     3509 |    76 |                0.0217 |     71 |                 0.0202 |      78 |                  0.0222 |
-- | 2012-05-01 |     3295 |   140 |                0.0425 |    151 |                 0.0458 |     150 |                  0.0455 |
-- | 2012-06-01 |     3439 |   164 |                0.0477 |    170 |                 0.0494 |     190 |                  0.0552 |
-- | 2012-07-01 |     3660 |   195 |                0.0533 |    187 |                 0.0511 |     207 |                  0.0566 |
-- | 2012-08-01 |     5318 |   264 |                0.0496 |    250 |                 0.0470 |     265 |                  0.0498 |
-- | 2012-09-01 |     5591 |   339 |                0.0606 |    285 |                 0.0510 |     331 |                  0.0592 |
-- | 2012-10-01 |     6883 |   432 |                0.0628 |    440 |                 0.0639 |     428 |                  0.0622 |
-- | 2012-11-01 |    12260 |   556 |                0.0454 |    571 |                 0.0466 |     624 |                  0.0509 |
-- | 2012-12-01 |     6643 |   464 |                0.0698 |    482 |                 0.0726 |     492 |                  0.0741 |
-- +------------+----------+-------+-----------------------+--------+------------------------+---------+-------------------------+

