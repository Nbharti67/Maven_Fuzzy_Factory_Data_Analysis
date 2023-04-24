/*Finding top traffic sources.
Email on 2012-12-04 (April 12th)
Email is 
We have been live for almost a month and we are starting to generate sales. Can you please help me 
understand where the bulk of our website sessions are coming from, through yesterday.
I'd like to see a breakdown by utm_source, utm_campaign amd referring domain if possible.*/
USE mavenfuzzyfactory;


SELECT 
utm_source,
utm_campaign,
http_referer,
COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-12-04'
GROUP BY utm_source,
		utm_campaign,
        http_referer
ORDER BY sessions DESC
;

/* Again Cindy replied with below message
Great Analysis!
Based on your findings, it seems like we should probably dig into gsearch nonbrand a bit deeper to see what we can do to optimize there.
Looping in Tom to assist you*/
-- -----------------------------------------------------------------------------------------------------------------------------------------------

/* Mail from Tom on 2012-04-14
Sounds like gsearch nonbrand is our major traffic source but we need to understand of those sessions are driving sales.
Could you please calculate the conversion rate (CVR) from session to order? Based on what we are paying for clicks, 
we'll need a CVR of atleast 4% to make numbers work.

If we are much lower, we'll need to decrease bid and if were higher we can increase bid to drive more volume */

SELECT 
COUNT( DISTINCT website_sessions.website_session_id) AS sessions,
COUNT(DISTINCT orders.website_session_id) AS No_of_orders,
COUNT(DISTINCT orders.website_session_id)/COUNT( DISTINCT website_sessions.website_session_id) AS cvr

FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source = "gsearch"
	AND website_sessions.utm_campaign = "nonbrand"
    AND website_sessions.created_at < '2012-04-14'
;

/* Reply from Tom (Marketing Director)
hmm, looks likewe are below the 4% threshold we need to make the economics work.
Based on this analysis, we'll need to dial down our search bids a bit .
 We ar over spending based on the current conversion rate.
 Nice work, your analysus just saved us some $$$!
 */
-- --------------------------------------------------------------------------------------------------------------------------
/* Hi There,
Based on your conversion rate analysis, we bid down gsearch nonbrand on 2012-04-15.
Can you pull gsearch nonbrand trended session volumne, by week, to see if the bid changes have caused volume to drop to all?
Thanks, Tom. */
SELECT 
YEAR(created_at) AS year,
WEEK(website_sessions.created_at) AS weeks,
MIN(DATE(created_at)) AS week_started_at,
COUNT(DISTINCT website_session_id) AS sessions

FROM website_sessions
WHERE utm_source ="gsearch"
	AND utm_campaign= "nonbrand"
    AND website_sessions.created_at < "2012-05-10"
GROUP BY WEEK(created_at),
		YEAR(created_at)
;

/* This is what Tom said on the analysis above
Hi there, great analysis!
okay, based on this, it does look like gsearch nonbrand is fairly sesitive to bid changes.
We want maximum volume, but don't want to spend more on ads than we can afford.
Let me think on this, I'll likely follow up with some ideas.
Thanks, Tom*/
-- ----------------------------------------------------------------------------------------------------------------------------

 /* Next email from Tom on May 11th 2012. 
 Hi there,
 I was trying to use our site on my mobile device the other day, and the experience was not great.
 Could you pull conversion rates from session to order, by device type?
 If desktop performance is better that on mobile we may be able to bidup for desktop specifically to get more volumes?
 Thanks, Tom 
 */
SELECT 
website_sessions.device_type,
COUNT(DISTINCT orders.website_session_id) AS orders,
COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
COUNT(DISTINCT orders.website_session_id)/COUNT(DISTINCT website_sessions.website_session_id) AS cvr
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id= orders.website_session_id
WHERE website_sessions.utm_source ="gsearch"
	AND website_sessions.utm_campaign = "nonbrand"
    AND website_sessions.created_at <"2012-05-11"
GROUP BY website_sessions.device_type
;


 /* Reply from Tom is
 Great!
 I am goint to increase our bids on desktop.
 When we bid higher, we'll rank higher in the auction, so I think your insights here should lead to a sales boost.
 Well done!!
 -Tom
 */
 
 /* Email from Tom on June 09th 2012
Hi there,
After your device-level analysis of conversion rates, we realized desktop was doing well,
 so we bid our gsearch nonbrand desktop campaigns up on 2012-05-19.
Could you pull weekly trends for both desktop and mobile so we can see the impact on volume?
You can use 2012-04-15 until the bid changs as a baseline. 
Thanks, Tom 
*/
SELECT 
WEEK(created_at) AS wk,
MIN(DATE(created_at)) AS week_start_date,
COUNT(DISTINCT(CASE WHEN device_type="desktop" THEN  website_session_id ELSE NULL END)) AS desktop_volume,
COUNT(DISTINCT(CASE WHEN device_type="mobile" THEN  website_session_id ELSE NULL END)) AS mobile_volume
FROM website_sessions
WHERE utm_source ="gsearch"
	AND utm_campaign ="nonbrand"
    AND created_at BETWEEN "2012-04-15" AND "2012-06-09" -- mail received on 2012-06-09
GROUP BY wk,
		YEAR(created_at)
;

/*Reply from Tom on June 09, 2012
SUbject" RE:Gsearcg device level trends

Nice work digging into this!
It looks like mobile has been preety flat or a little down, but desktop is looking strong,
 thanks to the bud changes we made based on your previous conversion analysis.
 
 Things are moving in the right direction!
 Thanks, Tom
 */
 
 
/* Finding top website pages
Email from Morgan Rockwell on June 09th 2012
Hi there!
I am Morgan, the new website manager.
Could you help me get my head around the site by pulling the most viewed website pages., ranked by session volume?
Thanks!
Morgan
*/
SELECT 
pageview_url,
COUNT(DISTINCT website_pageview_id) AS session_volume
FROM website_pageviews
WHERE created_at <"2012-06-09"
GROUP BY pageview_url
ORDER BY session_volume DESC
;

/* This is what Morgan replied
Thank you!
It definitely seems like the homepage, the product page, and the Mr. Fuzzy page get the bulk of our traffic.
I would like to understand traffic patterns more.
I'll follow up soon with a request to look at entry pages.
Thanks!
Morgan
Next Steps:
1. Dig into whether this list is also representative of our top entry page.
2. Analyze the performance of each of our top page to look for improvement opprotunity
*/



/*Finding top entry page
Email form Morgan Rockwell on JUne 12, 2012
Hi there!
Would you be able to pull a list of the top entry pages? I want to confirm where our users 
are hitting the site.
If you could pull all entry pages and rank them on entry volume, tha would be great.
Thanks!
-Morgan
*/

-- STEP 1:Find the first pageview for each session
-- STEP 2: Find the url the customer saw on that first pageview
CREATE TEMPORARY TABLE first_pv_per_session
SELECT 
	website_session_id,
	MIN(website_pageview_id) AS min_pv
FROM website_pageviews
WHERE created_at < "2012-06-12"
GROUP BY website_session_id
;

SELECT 
	website_pageviews.pageview_url AS landing_page_url,
    COUNT(DISTINCT first_pv_per_session.website_session_id) AS sessions_hitting_page
FROM first_pv_per_session
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = first_pv_per_session.min_pv
GROUP BY landing_page_url
ORDER BY sessions_hitting_page
;

/*Reply from Morgan Rockwell on June 12, 2012
Subject: Top Entry Pages
Wow, looks loke oyr traffic all comes in through the homepage right now!

Seems preety obvious where we should focus on making any improvements.
I will likely have some follow up requests to look into performance 
for the homepage. -- staty tuned!
Thanks,
-Morgan
*/


/* ANalyzing Bounce rate and landing page tests*/

/* Email from Morgan Rockwell on June 14, 2012
Subject: Bounce rate analysis

Hi there!
The other day you showed us that all of our traffic is landing on the homepage right now.
We should check how that landing page is performing.

Can you pull bounce rates for traffic landing on the homepage? I would like to see three 
numbers... Sessions, Bounced sessions and % of sessions which bounced (aka " Bounce rate")

Thanks!
-Morgan
/*Bounces have no pageview after first pageview and non bounce have additional 
pageview after firstpageview*/

/*STEPS
STEP 1: Find the first website_pagview_id for all  session. 
STEP 2: Find the landing page url of each session. 
STEP 3: Count the pageviews for each session, to identify bounce. 
STEP 4: Find the sessions, bounced sessions and % of sessions which bounced.  Summarizing total sessions and bounced sessions, by LP
*/

CREATE TEMPORARY TABLE first_pageviews
SELECT 
	website_sessions.website_session_id AS sessions,
    MIN(website_pageviews.website_pageview_id) AS min_pv_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-06-14'
GROUP BY sessions
-- ORDER BY min_pv_id
;

-- STEP 2: Find the landing page url of each session. 
CREATE TEMPORARY TABLE seesion_w_home_landing_page
SELECT 
	first_pageviews.sessions,
    first_pageviews.min_pv_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews
	LEFT JOIN website_pageviews
		ON first_pageviews.min_pv_id = website_pageviews.website_pageview_id
WHERE website_pageviews.pageview_url = '/Home'
;

-- STEP 3: Count the pageviews for each session, to identify bounce. 
CREATE TEMPORARY TABLE bounced_sessions
SELECT 
	seesion_w_home_landing_page.sessions,
    seesion_w_home_landing_page.landing_page,
	COUNT(website_pageviews.website_pageview_id) AS count_of_pages_viewed
FROM seesion_w_home_landing_page
	LEFT JOIN website_pageviews
		ON seesion_w_home_landing_page.sessions = website_pageviews.website_session_id
GROUP BY seesion_w_home_landing_page.sessions,
		seesion_w_home_landing_page.landing_page
HAVING count_of_pages_viewed = 1
;

-- STEP 4: Find the sessions, bounced sessions and % of sessions which bounced.  Summarizing total sessions and bounced sessions, by LP
SELECT 
	COUNT( DISTINCT seesion_w_home_landing_page.sessions) AS total_session,
    COUNT(DISTINCT bounced_sessions.sessions) AS bounced_sessions,
    COUNT(DISTINCT bounced_sessions.sessions) / COUNT( DISTINCT seesion_w_home_landing_page.sessions) AS bounced_session_percent
FROM seesion_w_home_landing_page
	LEFT JOIN bounced_sessions
		ON bounced_sessions.sessions = seesion_w_home_landing_page.sessions
;

/* 
Reply form Morgan on June 14th 2012
SUbject : RE Bounce rate analysis
Ouch..almost a 60% bounce rate!
That's preety high from my experience, especially for paid search, which should be high 
quality traffic.
I'll put together a custom landing page for search and seat up an experience to see if 
the new page does better. I will likely need your help analyzing the test once we
 get enough data to judge performance.
Thanks Morgan*/


-- -----------------------------------------------------------------------------------------------
/* email from Morgan on July 28, 2012
SUbject: Help analyzing LP test
Hi there!,
Based on your bounce rate analysis, we ran a new custom landing page (/lander-1) in a 50/50 
test against the homepage(/home) for our gsearch nonbrand traffic.
Can you pull bounce rates for the two groups so we can evaluate the new page? Make sure 
to just look at the time period where /lander-1 was getting traffic, so that it is a
 fair comparison.
Thanks, Morgan
*/
-- Steps:
-- STEP 0: Find out when the new page/lander launched
-- STEP 1: Finding the first website_pageview_id for relevant sessions
-- STEP 2: Identifying the landing page of each session
-- STEP 3: Counting pageviews for each session, to identify "bounces
-- STEP 4:"Summarizing total sessions and bounced sessions, by LP

-- STEP 0: Find out when the new page/lander launched
-- STEP 0: Find out when the new page/lander launched
SELECT 
	MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL
;
-- first_created_at = 2012-06-19 00:35:54
-- first_pageview_id = 23504



-- STEP 1: Finding the first website_pageview_id for relevant sessions
CREATE TEMPORARY TABLE first_test_pageviews
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
   -- website_pageviews.pageview_url
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_pageviews.website_session_id = website_sessions.website_session_id
        AND website_sessions.created_at < '2012-07-28'-- prescribed by the assignment
        AND website_pageviews.website_pageview_id > 23504 -- the min pageview id we found
        AND utm_source ='gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY 
	website_pageviews.website_session_id
;

SELECT * FROM first_test_pageviews;



-- Next we'll bring in the landing page to each session, like last time, but restricting to 
-- home page or lander-1 this time. 
-- STEP 2: Identifying the landing page of each session
CREATE TEMPORARY TABLE nonbrand_test_sessions_w_landing_page
SELECT 
	first_test_pageviews.website_session_id,
    -- website_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
     -- first_pageviews.pageview_url AS landing_page
FROM first_test_pageviews
	LEFT JOIN website_pageviews
		ON first_test_pageviews.min_pageview_id = website_pageviews.website_pageview_id
        -- AND website_pageviews.pageview_url = '/home' ( giving me wrong result)
        -- OR website_pageviews.pageview_url = '/lander-1' (giving me wrong result)
WHERE website_pageviews.pageview_url in ('/home', '/lander-1')
-- GROUP BY 	first_test_pageviews.website_session_id ( do not need to do group by)
;

SELECT * FROM nonbrand_test_sessions_w_landing_page;



-- then a table to have count of pageviews per session
-- then limit it to just bounced sessions
 -- STEP 3: Counting pageviews for each session, to identify "bounces
 CREATE TEMPORARY TABLE nonbrand_test_bounced_sessions
 SELECT 
	  nonbrand_test_sessions_w_landing_page.website_session_id,
      nonbrand_test_sessions_w_landing_page.landing_page,
      COUNT(DISTINCT website_pageviews.website_pageview_id) AS count_of_pages_viewed
 FROM  nonbrand_test_sessions_w_landing_page
	LEFT JOIN website_pageviews
		ON  nonbrand_test_sessions_w_landing_page.website_session_id = website_pageviews.website_session_id
GROUP BY  nonbrand_test_sessions_w_landing_page.landing_page,
		  nonbrand_test_sessions_w_landing_page.website_session_id
HAVING COUNT( website_pageviews.website_pageview_id) = 1
;

SELECT * FROM nonbrand_test_bounced_sessions;



-- do this first to show, then count them after
-- Here bounced and unbounced session has been shown
-- unbounced_website_sessions_id are shown with NULL value and bounced_website_session_id with session_id value.
SELECT
	nonbrand_test_sessions_w_landing_page.landing_page,
    nonbrand_test_sessions_w_landing_page.website_session_id,
    nonbrand_test_bounced_sessions.website_session_id AS bounced_website_session_id
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN nonbrand_test_bounced_sessions
		ON nonbrand_test_sessions_w_landing_page.website_session_id =  nonbrand_test_bounced_sessions.website_session_id
ORDER BY 
	 nonbrand_test_sessions_w_landing_page.website_session_id
;



-- final output for Assignment_Analyzing_landing_page_tests
	-- show this aggregate summary level as a build from the previous step with individual sessions as output.
SELECT
	nonbrand_test_sessions_w_landing_page.landing_page,
    COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id)/COUNT(DISTINCT nonbrand_test_sessions_w_landing_page.website_session_id) AS bounce_rate
	-- (bounced_sessions/sessions) AS bounce_rate ==> doesn't work
FROM nonbrand_test_sessions_w_landing_page
	LEFT JOIN nonbrand_test_bounced_sessions
		ON nonbrand_test_sessions_w_landing_page.website_session_id =  nonbrand_test_bounced_sessions.website_session_id
GROUP BY 
		nonbrand_test_sessions_w_landing_page.landing_page
;


/* Reply from Morgan on July 28th 2012
Hey!
This is so great. It looks like the custom lander has a lower bounce rate... success!
I will work with Tom to get campaigns updated so that all nonbrand paid traffic is pointing to the new page.
In a few weeks, I would like you to take a look at trends to make sure things have moved in the right direction.
Thanks, Morgan
*/
-- ----------------------------------------------------------------------------------------------------

/* LANDING PAGE TREND ANALYSIS
New email from Morgan on August 31st 2012
Hi there,
Could you pull the volume of paid search nonbrand traffic landing on/home and /lander-1, 
trended weekly since june 1st? 
I want to confirm the traffic is all routed correctly.
Could you also pull our overall paid search bounce rate trended weekly? 
I want to make sure the lander change has improved the overall picture.
Thanks!
*/
/*
Week_start_date    bounce_rate    home_session    lander_session
*/

-- STEP 1: Finding the first website_pageview_id for relevant sessions
-- STEP 2: Identifying the landing page of each session
-- STEP 3: Counting pageviews for each session, to identify "bounces"
-- STEP 4: Summarizing by week (bounce rate, sessions to each lander)

-- STEP 1: Finding the first website_pageview_id for relevant sessions
CREATE TEMPORARY TABLE sessions_w_min_pv_id_and_view_count
SELECT 
	website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews

FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = website_sessions.website_session_id
	
WHERE website_sessions.created_at > '2012-06-01'
	AND website_sessions.created_at < '2012-08-31'
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'

GROUP BY website_sessions.website_session_id
;

SELECT * FROM sessions_w_min_pv_id_and_view_count;



-- STEP 2: Identifying the landing page of each session
CREATE TEMPORARY TABLE sessions_w_count_lander_and_created_at
SELECT 
	sessions_w_min_pv_id_and_view_count.website_session_id,
    sessions_w_min_pv_id_and_view_count.first_pageview_id,
    sessions_w_min_pv_id_and_view_count.count_pageviews,
    website_pageviews.pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
FROM sessions_w_min_pv_id_and_view_count
	LEFT JOIN website_pageviews
		ON sessions_w_min_pv_id_and_view_count.first_pageview_id = website_pageviews.website_pageview_id
-- GROUP BY 
	-- sessions_w_min_pv_id_and_view_count.website_session_id,
    -- sessions_w_min_pv_id_and_view_count.first_pageview_id
;

SELECT * FROM sessions_w_count_lander_and_created_at;




-- STEP 3: Counting pageviews for each session, to identify "bounces"
/*
SELECT 
	sessions_w_count_lander_and_created_at.website_session_id,
    sessions_w_count_lander_and_created_at.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count
FROM sessions_w_count_lander_and_created_at
	LEFT JOIN website_pageviews
    ON  sessions_w_count_lander_and_created_at.first_pageview_id = website_pageviews.website_session_id

GROUP BY sessions_w_count_lander_and_created_at.website_session_id
HAVING COUNT(website_pageviews.website_pageview_id) = 1
;
*/
-- Whenever there is group by, use having not where
SELECT
	YEARWEEK(session_created_at) AS year_week,
    MIN(DATE(session_created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT website_session_id) AS bounce_rate,
    COUNT(DISTINCT CASE WHEN landing_page = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_page = '/lander-1' THEN website_session_id ELSE NULL END) AS lander_sessions 
    
    FROM sessions_w_count_lander_and_created_at
    
    GROUP BY
		YEARWEEK(session_created_at)
	; 
    
    /* Reply from Morgan after showing the data to Morgan
    Mail from Morgan on Aug 31st 2012.
    This is greate. Thank you!
    Looks like both pages were getting traffic for a while, and then we fully switched over to the 
    custom lander, as intended. And it looks like our overall bounce rate has come down over time...nice!
    I am going to do a full deep dive into our site, and will follow up with aks.
    Thanks!
    -Morgan
		
        
        
/* Email from Morgan on Sept 05 2012
Hi there!
I'd like to understand where we lose our gsearch visitors between the new /lander-1 page
and placing an order. Can you build us a full conversion funnel, analyzing how many customers
make it to each step?
Starting with /lander-1 and build the funnel al the way to our thank you page. 
Please use data since August 5th.
Thanks!
Morgan
 */
 
 -- STEP 1: Select all pageviews for relevant sessions.
 -- STEP 2: Identify each pageview as the specific funnel steps.
 -- STEP 3: Create the session level conversion funnel view
 -- STEP 4: Aggregate the data to assess funnel perfomance
 
 USE mavefuzzyfactory;
 
 -- lets look at this first, then we will use it as a subquery to do 
SELECT
	DISTINCT pageview_url
FROM website_pageviews
WHERE created_at BETWEEN '2012-08-05' AND '2012-09-05'
;

SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url =  '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
    
 FROM website_sessions
	LEFT JOIN website_pageviews
    ON website_sessions.website_session_id = website_pageviews.website_session_id
 WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
	AND website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05'
ORDER BY website_sessions.website_session_id,
website_pageviews.created_at
;



CREATE TEMPORARY TABLE session_level_made_it_flag
SELECT 
	website_session_id,
    MAX(products_page) AS products_made_it,
    MAX(mrfuzzy_page) AS mrfuzzy_made_it,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it
FROM 
(SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at AS pageview_created_at,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
	CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url =  '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
    
 FROM website_sessions
	LEFT JOIN website_pageviews
    ON website_sessions.website_session_id = website_pageviews.website_session_id
 WHERE website_sessions.utm_source = 'gsearch'
	AND website_sessions.utm_campaign = 'nonbrand'
	AND website_sessions.created_at BETWEEN '2012-08-05' AND '2012-09-05'

ORDER BY website_sessions.website_session_id,
	      website_pageviews.created_at
) AS pagview_level
GROUP BY website_session_id	
;

SELECT * FROM  session_level_made_it_flag;



-- then this would produce the final output
SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) AS to_thankyou
    
FROM  session_level_made_it_flag
;



SELECT 
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS lander_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) / COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END)  AS product_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_clickthrough_rate,
    COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_clickthrough_rate
    
FROM  session_level_made_it_flag
;


/*
Reply from Morgan on Sept 05th 2012
This analysis is really helpful!
Looks like we should focus on the lander, Mr. Fuzzy page, and the billing page, 
which have the lowest click rates.
I have some ideas for the billing page that I thinK will make customers more 
comfortable entering their credit card info. I'll test a new page soon
and will ask for help analyzing performance.
Thanks!
Morgan
*/



/* New email from Morgan on Nov 10th 2012
Subject: Conversion funnel test results
Hello!
We tested an updated billing page based on your funnel analysis. Can you take a look and see 
whether /billing-2 is doing any better than the original /billing page?
We are wondering what % of sessions on those pages end up placing an order.
 FYI - We ran this test for all traffic, not just for our search visitors.
 Thanks!
 Morgan
 */
 
 SELECT 
	MIN(website_session_id) AS first_website_session_id,
    MIN(website_pageview_id) AS first_pv_id,
    MIN(created_at) AS first_created_at
    
FROM website_pageviews
WHERE pageview_url = '/billing-2'
;
-- from this analysis, first_pv_id =53550
-- first, we'll look at this without orders, then we'll add in orders. 
SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id
FROM website_pageviews
	LEFT JOIN orders
    ON website_pageviews.website_session_id = orders.website_session_id

WHERE website_pageviews.website_pageview_id > 53550
AND website_pageviews.created_at < '2012-11-10'
AND website_pageviews.pageview_url IN ('/billing', '/billing-2')
;


SELECT 
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS billing_to_order_rate
FROM
(
SELECT 
	website_pageviews.website_session_id,
    website_pageviews.pageview_url AS billing_version_seen,
    orders.order_id
FROM website_pageviews
	LEFT JOIN orders
		ON website_pageviews.website_session_id = orders.website_session_id
        
WHERE website_pageviews.created_at < '2012-11-10'
AND website_pageviews.website_pageview_id > 53550
AND website_pageviews.pageview_url IN ('/billing', '/billing-2')
) AS billing_sessions_w_orders
GROUP BY
	billing_version_seen
;


/*
Email from Morgan on Nov 10th 2012
This is so good to see!
Looks like the new version of the billing page is doing a much better job converting customers..Yes!!
I will get engineering to roll this out to all of our customers right away. Your insights
just made us some major revenue.
Thanks so much!
-Morgan
*/
/* NEXT STEP:
After Morgan gets engineering roll out the new version to  100% of traffic, use the data 
to confirm they have done so correctly.
Monitor overall sales performance to see the impact this change produced.
*/