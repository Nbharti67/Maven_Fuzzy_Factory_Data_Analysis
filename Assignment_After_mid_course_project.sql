USE mavenfuzzyfactory;
/* Email from Tom Parmesan on 2012-11-29
Subject: Expanded channel portfolio
Hi there,
With gsearch doing well and the site performing there, we launched a second paid search channel,
bsearch, around August 22. 

Can you pull weekly trended session volumne since then and compare to gsearch nonbrand so I can
get a sense for how important this will be for the business?

Thanks, Tom

week_start_date, gsearch_sessions, bsearch_sessions
*/
SELECT 
YEARWEEK(created_at) AS yrwk,
MIN(DATE(created_at)) AS week_start_date,
COUNT(DISTINCT website_session_id) AS Total_sessions,
COUNT(CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch,
COUNT(CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22'AND  '2012-11-29'
AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at)
;

/* Reply from Tom
Hi there, 
This is very helpful to see. It looks like bsearch tends to get roughly a third the traffic of gsearch.
This is big enough that we should really get to know the channel better.
I will folow up with some requests to understand channel characteristics and conversion performance.
Thanks Tom
*/


/* New email from Tom Parmesan on November 30th, 2012
Subject: Comparing our channels
Hi there,
I'd like to learn more about the bsearch nonbrand campaign. 
Could you please pull the percentage of traffic coming on Mobile, and compare that to gsearch. 

Feel free to dig around and share anything else you find interesting. Aggregate data since 
August 22nd is great, no need to show trending at this point.
Thanks, Tom
utm_source   sessions   mobile_session  percetange_on_mobile  
*/
SELECT 
utm_source,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(CASE WHEN device_type='mobile' THEN website_session_id ELSE NULL END) AS mobile_session,
COUNT(CASE WHEN device_type='mobile' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS percentage_on_mobile
FROM website_sessions
WHERE created_at BETWEEN '2012-08-22' AND '2012-11-30'
	AND utm_campaign ='nonbrand'
GROUP BY utm_source
;

/* Reply form Tom
Wow, the desktop to mobile splits are very interesting. These channels are quite different 
from a device standpoint.
Let's keep this in mind as we continue to learn and optimize. Now that we know these channels
are preety different, I'm going to need your help digging in a bit more so that we can get our 
bids right.
Thanks, and keep up the great work!
-Tom
*/


/* Cross Channel Bid Optimization - Multi channel bidding
Email from Tom on December 01, 2012
Hi there,
I'm wondering if bsearch nonbrand should have the same bids as gsearch. Could you pull nonbrand 
conversion rates from session to order gsearch and bsearch, and slice the date by device type.

Please analyze data from August 22 to September 18, we ran a special pre-holiday campaign for 
gsearch starting on September 19th, so the data after that isn't fair game.
Thanks, Tom

data_type utm_source sessions orders conv_rate  
*/
SELECT 
website_sessions.device_type AS device,
website_sessions.utm_source AS utm_source,
COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
COUNT(DISTINCT orders.order_id) AS total_orders,
COUNT(DISTINCT orders.order_id) /COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_campaign = 'nonbrand'
	AND website_sessions.created_at BETWEEN '2012-08-22' AND '2012-09-19'
GROUP BY website_sessions.device_type,
		website_sessions.utm_source 
;

/* Reply form Tom
Thanks, this is good to see.
As I suspected, the channels don't perform identically, so we should differentiate our
 bids in order to optimize our overall paid marketing budget. I'll bid down bsearch based
 on its under performance.
 Great work!
 Tom
 */
 
 
 /* Analyzing Channel Portfolio Trends 
 Email from Tom on Dec 22, 2012
Channel Portfolio Trends
Subject: Impact of Bid changes
Hi there,
Based on your last analysis, we bid down bsearch nonbrand on December 2nd.
Can you pull weekly session volume for gsearch and bsearch nonbrand, broken down by device,
 since Novemeber 4th?

If you can include a comparison metric to show bsearch as a percent of gsearch to each device, 
that would be great too.
Thanks, Tom

week_start_date, g_dtop_sessions,  b_dtop_sessions,  b_pct_of_g_dtop, g_mob_sessions, b_mob_sessions,
 b_pct_of_g_mob
 week_start_date, 
*/
SELECT 
MIN(DATE(created_at)) AS wk_start_date,
COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'Desktop' THEN website_session_id ELSE NULL END) AS g_dtop_sessions,
COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'Desktop' THEN website_session_id ELSE NULL END) AS b_dtop_sessions,
COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'Desktop' THEN website_session_id ELSE NULL END) / 
COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'Desktop' THEN website_session_id ELSE NULL END) AS b_pct_of_g_dtop,
COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'Mobile' THEN website_session_id ELSE NULL END) AS g_mob_sessions,
COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'Mobile' THEN website_session_id ELSE NULL END) AS b_mob_sessions,
COUNT(CASE WHEN utm_source = 'bsearch' AND device_type = 'Mobile' THEN website_session_id ELSE NULL END) /
COUNT(CASE WHEN utm_source = 'gsearch' AND device_type = 'Mobile' THEN website_session_id ELSE NULL END) AS  b_pct_of_g_mob
FROM website_sessions
WHERE created_at BETWEEN '2012-11-04' AND '2012-12-22'
	AND utm_campaign = 'nonbrand'
GROUP BY YEARWEEK(created_at)
;

/* Reply form Tom
Hi there,
Thanks for pulling this together!
Looks like bsearch traffic dropped off a bit after the bid down. Seems like gsearch was down too
after black friday and cyber Mondat, but bsearch dropped even more. 
I think this is okay given the low conversion rate.
Thanks, Tom

Next steps:
Spend some time trying to fully grasp the results of this data.
Think about which of these metrics best control for the seasonality Tom mentioned and isolates the
impact of the bsearch bid changes
*/



/* Email from Cindy Sharp on December 23, 2012
Subject: Site Traffic breakdown
Good morning,
A potential investor is asking if we are building any momentum with our brand or if we
need to keep relying on paid traffic.
Could you pull organic search, direct type in and paid brand search session by month, and 
show those sessions as a % of paid search nonbrand?
 Cindy
 */
 
SELECT 
	YEAR(created_at),
	MONTH(created_at),
    COUNT(CASE WHEN channel_group = 'paid_brand' THEN website_session_id ELSE NULL END) AS paid_brand_session,
    COUNT(CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS paid_nonbrand_session,
    COUNT(CASE WHEN channel_group = 'paid_brand' THEN website_session_id ELSE NULL END )/   
    COUNT(CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS brand_pct_of_nonbrand,
    
	COUNT(CASE WHEN channel_group = 'organic_search' THEN website_session_id ELSE NULL END) AS organic_search_sessions,
    COUNT(CASE WHEN channel_group = 'organic_search' THEN website_session_id ELSE NULL END )
    /COUNT(CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS organic_pct_of_nonbrand,
    
    
    COUNT(CASE WHEN channel_group = 'direct_typein' THEN website_session_id ELSE NULL END) AS direct_typein_sessions,
     COUNT(CASE WHEN channel_group = 'direct_typein' THEN website_session_id ELSE NULL END)
     /COUNT(CASE WHEN channel_group = 'paid_nonbrand' THEN website_session_id ELSE NULL END) AS direct_typein_pct_of_nonbrand
     
FROM
(
 SELECT 
 website_session_id,
 created_at,
 CASE
	WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
    WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_typein'
    WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
    WHEN utm_campaign = 'brand' THEN 'paid_brand'
END AS channel_group
FROM website_sessions
WHERE created_at <'2012-12-23'
) AS session_w_channel_group
GROUP BY YEAR(created_at),
		MONTH(created_at)
;


/* Reply from Cindy Sharp
This is great to see!
Looks like only areour brand, direct and organic volumes growing, but they are growing as a percentage of
our paid traffic volume.
Now this is a story I can sell to an investor!
-Cindy
*/



-- ----------------------------------------------------------------------------------------------------------------------------------
/* New email from Cindy Sharp on Jan 02, 2013
Subject: Understanding seasonality
Good Morning,
2012 was a great year for us. As we continue to grow, we should take a look at 2012's monthly 
and weekly volume patterns, to see if we can find any seasonal trends we should plan for in 2013.
If you can pull session volume and order volume, that would be excellent. 
Thanks,
-Cindy
*/
SELECT 
YEAR(website_sessions.created_at),
MONTH(website_sessions.created_at),
WEEKDAY(website_sessions.created_at),
MIN(DATE(website_sessions.created_at)) AS week_start_date,
COUNT(DISTINCT website_sessions.website_session_id) AS session_volume,
COUNT(DISTINCT orders.order_id) AS order_volume
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2011-12-31' AND '2013-01-01'
GROUP BY YEAR(website_sessions.created_at),
		WEEKDAY(website_sessions.created_at)
;

/* Reply from Cindy
This is great to see.
Looks like we grew fairly steadily all year, and saw significant volume around the holiday months
(especially the weeks of black friday and cyber Monday). 
We'll want to keep this in mind in 2013 as we think about customer support and 
inventory management.

Great analysis!
-Cindy
*/


/* Email from Cindy Sharp on Jan 05th 2013.
Subject : Data for customer service.
Good morning,
We are considering adding live chat support to the website to improve our customer experience. 
Could you analyze the average website session volume, by hour of day and by day week, so that 
we can staff appropriately?
Let's avoid the holiday time period and use a date range of sep 15- Nov 15, 2012.
Thanks, Cindy
*/
SELECT 
	hr,
    ROUND(AVG(website_sessions)) AS avg_sessions,
    ROUND(AVG(CASE WHEN wkday=0 THEN website_sessions ELSE NULL END),1) AS Monday,
    ROUND(AVG(CASE WHEN wkday=1 THEN website_sessions ELSE NULL END),1) AS Tuesday,
    ROUND(AVG(CASE WHEN wkday=2 THEN website_sessions ELSE NULL END),1) AS Wednesday,
    ROUND(AVG(CASE WHEN wkday=3 THEN website_sessions ELSE NULL END),1) AS Thursday,
    ROUND(AVG(CASE WHEN wkday=4 THEN website_sessions ELSE NULL END),1) AS Friday,
    ROUND(AVG(CASE WHEN wkday=5 THEN website_sessions ELSE NULL END),1) AS Saturday,
    ROUND(AVG(CASE WHEN wkday=6 THEN website_sessions ELSE NULL END),1) AS Sunday
FROM
(
SELECT 
	DATE(created_at) as created_date,
    WEEKDAY(created_at) AS wkday,
	HOUR(created_at) as hr,
    COUNT(DISTINCT website_session_id) AS website_sessions

FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY DATE(created_at),
		WEEKDAY(created_at),
		HOUR(created_at)
) AS daily_hourly_sessions
GROUP BY hr
ORDER BY hr
;

/* Reply from Cindy on January 05, 2013
Thanks, this is really helpful.
I have been speaking with support companies, and it sounds like ~10 sessions per hour
 per employee staffed is about right.
 Looks like we can plan on one support staff around the clock and then we should double 
 up to two staff members from 8 am to 5pm Monday through Friday.
 -Cindy
 */
 
 -- ------------------------------------------------------------------------------------------------------------------------------------------------
 /*
Email from Cindy Sharp on January 4th, 2023
Good morning,
We're about to launch a new product, and I'd like to do a deep dive on our current flagship 
product. 
Can you please pull monthly trends to date for number of sales, total revenue,
 and total margin generated for the business?
 -Cindy
*/

SELECT 
	YEAR(created_at) AS yr,
	MONTH(created_at) AS mo,
    COUNT(DISTINCT order_id) AS mumber_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd-cogs_usd) AS total_margin
FROM orders 
WHERE created_at < '2013-01-04'
GROUP BY YEAR(created_at),
	MONTH(created_at)
;
 
 /*Reply from Cindy
Excellent, Thank you!
This will serve as great baseline data so that we can see how our revenue and margin
 evolve as we roll out the new product.
 It's also nice to see our growth pattern in general.
 Thanks again,
 -Cindy
 */
 
 /* Email from Cindy Sharp on April 05th, 2013
Good morning,
We launched our second product back on January 6th. Can you pull together some trended analysis?

I'd like to see monthly order volume, overall conversion rates, revenue per session, and a breakdown of sales
by product, all for the time period since April 1, 2012.
Thanks,
-Cindy
*/
SELECT
YEAR(website_sessions.created_at) AS yr,
MONTH(website_sessions.created_at) AS mo,
COUNT(DISTINCT orders.order_id) AS order_volume,
COUNT(DISTINCT website_sessions.website_session_id) AS total_sessions,
COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
SUM(orders.price_usd)/ COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session,
COUNT(DISTINCT CASE WHEN primary_product_id =1 THEN orders.order_id ELSE NULL END) AS product_one_orders,
COUNT(DISTINCT CASE WHEN primary_product_id =2 THEN orders.order_id ELSE NULL END) AS product_two_orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id=orders.website_session_id
WHERE website_sessions.created_at BETWEEN '2012-04-01' AND '2013-05-05'
GROUP BY MONTH(website_sessions.created_at),
		YEAR(website_sessions.created_at)
ORDER BY yr
;

/* Reply from Cindy
Thanks!
This confirms that our conversion rate and revenue per session are improving over time, which 
is great.
I'm having a hard time understanding if the growth since January is due to our new product 
launch or just a continuation of our overall business improvements.

I'll connect with Tom about digging into this some more.
-Cindy
*/

/* New email from Morgan Rockwell on April 6th, 2013
Subject: Help w/user pathing
Hi there!
Now that we have a new product, I am thinking about our user path and conversion funnel.
Let's look at sessions which hit the/products page and see where they went next.

Could you please pull clickthrough rates from /products since the new product launch on January 
6th 2013, by product, and compare to the 3 months leading up to launch as a baseline?
Thanks, Morgan
time period,           sessions_w_next_page,      pct_w_next_pg,      to_mrfuzzy,      to_lovebear,      pct_to_lovebear
a. pre_product_2
post_product_2
*/
/* Doubts are 
why we don't get correct answer if we change the order of tables in the left join. i.e.orders left join website_sessions & website_sessions left join orders.
Why don't I get correct answer if I do order.website_session_id in place of website_sessions.website_session_id, This happens while left joining.
*/


-- STEP 1: Finding the relevant '/products' pageviews with website_session_id
-- STEP 2: Finding the next pageview_id that occurs after the product pageview
-- STEP 3: Find the pageview_url associated with any applicable next pageview_id
-- STEP 4: Summarize the data and analyze the pre vs post periods

CREATE TEMPORARY TABLE product_pageviews
SELECT
	website_session_id,
	website_pageview_id,
    created_at,
    
    CASE
		WHEN created_at <'2013-01-06' THEN 'A. Pre_product_2'
        WHEN created_at > '2013-01-06' THEN 'B. Post_product_2'
        ELSE 'uh oh.....check the logic'
	END AS time_period
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-06' AND '2013-04-06'
	AND pageview_url = '/products'
;
SELECT * FROM product_pageviews;


-- STEP - 2 : Find the next pageview_id that occurs after the product pageview. 
CREATE TEMPORARY TABLE sessions_w_next_pageview_id
SELECT 
	product_pageviews.time_period,
    product_pageviews.website_session_id,
    website_pageviews.pageview_url,
    MIN(website_pageviews.website_pageview_id) AS min_next_pageview_id
FROM product_pageviews 
	LEFT JOIN website_pageviews   -- here first product_pageview then website_pageviews else this will show error in time period
		ON website_pageviews.website_session_id = product_pageviews.website_session_id
        AND website_pageviews.website_pageview_id > product_pageviews.website_pageview_id
GROUP BY 1,2
;
SELECT * FROM sessions_w_next_pageview_id;



-- STEP 3 : Find the pageview_url associated with any applicable next pageview_id
CREATE TEMPORARY TABLE sessions_w_next_pageview_url
SELECT 
	sessions_w_next_pageview_id.time_period,
    sessions_w_next_pageview_id.website_session_id,
    website_pageviews.pageview_url
FROM sessions_w_next_pageview_id
	LEFT JOIN website_pageviews
		ON sessions_w_next_pageview_id.min_next_pageview_id = website_pageviews.website_pageview_id -- here min_next_pageview_id is used because a website_session_has
        -- several pageview_id. Those pageview id may contain the one which is before '/products' in conversion flow
;
SELECT * FROM sessions_w_next_pageview_url;



-- Just to show the distinct next pageview_url
SELECT 
	DISTINCT pageview_url
FROM sessions_w_next_pageview_url;

-- STEP 4: Summarize the data and analyze the pre vs. post periods. 
SELECT 
	time_period,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN pageview_url IS NULL THEN website_session_id ELSE NULL END) AS w_next_page,
    COUNT(DISTINCT CASE WHEN pageview_url IS NULL THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS pct_w_next_page,
    
    COUNT(DISTINCT CASE WHEN pageview_url ='/the-original-mr-fuzzy'THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN pageview_url ='/the-original-mr-fuzzy'THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS pct_mrfuzzy_page,
    
    COUNT(DISTINCT CASE WHEN pageview_url ='/the-forever-love-bear'THEN website_session_id ELSE NULL END) AS to_love_bear_page,
    COUNT(DISTINCT CASE WHEN pageview_url ='/the-forever-love-bear'THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) AS pct_to_lovebear_pagr
    
FROM sessions_w_next_pageview_url
GROUP BY time_period
;

/* Reply from Morgan
Great Analysis!
Looks like the percent of '/products' pageviews that clicked to Mr. Fuzzy has gone wrong since 
the launch of the love Bear, but the overall clickthroughrate has gone up, so it seems to
be generating additional product interest overall.
As a followup, we should probably look at the conversion funnels for each product individually.

Thanks!
-Morgan
*/



/* Email from Morgan Rockwell on April 10, 2014.
Subject: Product conversion funnels
Hi there!
I'd like to look at our two products since January 6th and analyze the conversion funnels
from each product page to conversion.

It would be great if you could produce a comparison between the two conversion funnels, for all
 website traffic.
 Thanks!
 -Morgan
 */
-- USE mavenfuzzyfactory;


-- STEP 1: Select all pageviews for relevant sessions
-- STEP 2: Figure out which pageview_url to look for
-- STEP 3: Pull all pageviews and identify the funnel steps
-- STEP 4: Create the session -level conversion funnel view
-- STEP 5: Aggregate the data to assess funnel performance



CREATE TEMPORARY TABLE session_seeing_product_pages
SELECT 
	website_session_id,
    website_pageview_id,
	pageview_url AS product_page_seen
    
FROM website_pageviews
WHERE created_at <'2013-04-10'
	AND created_at > '2013-01-06'
	AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear')
;


-- Finding the right pageview_urls to buils the funnels.
SELECT DISTINCT
	website_pageviews.pageview_url
FROM session_seeing_product_pages
	LEFT JOIN website_pageviews
		ON session_seeing_product_pages.website_session_id = website_pageviews.website_session_id
		AND session_seeing_product_pages.website_pageview_id < website_pageviews.website_pageview_id
;



-- We'll look at the inner query first to look over the pageview-level results.
-- then, turn it into a subquery and make it the summary with flags
SELECT
	session_seeing_product_pages.website_session_id,
    session_seeing_product_pages.product_page_seen,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0  END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
    
FROM session_seeing_product_pages
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = session_seeing_product_pages.website_session_id
        AND website_pageviews.website_pageview_id > session_seeing_product_pages.website_pageview_id

ORDER BY 
	session_seeing_product_pages.website_session_id,
    website_pageviews.created_at
;



-- CREATE TEMPORARY TABLE session_product_level_made_it_flags
SELECT
	website_session_id,
	CASE 
		WHEN product_page_seen = '/the-orignal-mr-fuzzy' THEN 'mrfuzzy'
		WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
        ELSE 'uh oh....check the logic'
	END AS product_seen,
    MAX(cart_page) AS cart_made_it,
    MAX(shipping_page) AS shipping_made_it,
    MAX(billing_page) AS billing_made_it,
    MAX(thankyou_page) AS thankyou_made_it

FROM 
(
SELECT
	session_seeing_product_pages.website_session_id,
    session_seeing_product_pages.product_page_seen,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0  END AS shipping_page,
    CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0  END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
    
FROM session_seeing_product_pages
	LEFT JOIN website_pageviews
		ON website_pageviews.website_session_id = session_seeing_product_pages.website_session_id
        AND website_pageviews.website_pageview_id > session_seeing_product_pages.website_pageview_id

ORDER BY 
	session_seeing_product_pages.website_session_id,
    website_pageviews.created_at
)AS pageview_level
GROUP BY 
	website_session_id,
    CASE 
		WHEN product_page_seen = '/the-orignal-mr-fuzzy' THEN 'mrfuzzy'
		WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
        ELSE 'uh oh....check the logic'
	END 
;
 
 
 
 /* This is great to see!
 We had enough that addidng a second poduct increase overall CTR frtm the/products page, 
 and this alalysis shows that the love bear has a better click rate to the /cart page and 
 comparable rates throughout the rest ofthe funnel.
 
 Seems like the second product was a great addition for our busniness. I wonder 
 if we should add a third..
 Thanks!
 -Morgan
 */
 
 
 
 
 
 /* Email from Cindy Sharp on Nov 22, 2013.
Subject: Cross selling performance
Good morning,
On September 25th, we started giving customers the option to add a 2nd product while on the/cart
 page. Morgan says this has been positive , but I'd like your take on it.
 
 Could you please compare the month before vs the month after the chnage? I'd like to see 
 CTR from the /cart page, Avg Products per Order, AOV, and overall revenue per /cart page 
 view.
 
 Thanks, Cindy
 time         CTR from the /cart page,     Avf products per order, AOV, overall revenue per/cart pageview
 month before
 month after
 ctr is click through rate
 average order value aov
 */
-- STEP 1: iDENTIFY THE RELEVANT /cart PAGEVIEWS AND THEIR SESSIONS
-- STEP 2: See which of those /cart sessions clicked through to the shipping page
-- STEP 3: Find the orders associated with the /cart sessions. Analyze products purchased
-- STEP 4: Aggregate and analyze a summary of our findings

CREATE TEMPORARY TABLE sessions_seeing_cart
SELECT 
	CASE
		WHEN created_at < '2013-09-25' THEN 'A. Pre_cross_sell'
        WHEN created_at >= '2013-09-25' THEN 'B. Post_cross_sell'
	END AS time_period,
	website_session_id AS cart_session_id,
    website_pageview_id AS cart_pageview_id
FROM website_pageviews
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
AND pageview_url = '/cart'
;

-- STEP 2: See which of those /cart sessions clicked through to the shipping page
 CREATE TEMPORARY TABLE cart_sessions_seeing_another_page
 SELECT 
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    MIN(website_pageviews.website_pageview_id) AS pv_id_after_cart
 FROM sessions_seeing_cart
	LEFT JOIN website_pageviews
		ON sessions_seeing_cart.cart_pageview_id < website_pageviews.website_pageview_id
        AND sessions_seeing_cart.cart_session_id = website_pageviews.website_session_id

GROUP BY sessions_seeing_cart.time_period,
		sessions_seeing_cart.cart_session_id
HAVING 
	MIN(website_pageviews.website_pageview_id) IS NOT NULL
;


 CREATE TEMPORARY TABLE pre_post_sessions_order
SELECT 
	time_period,
    sessions_seeing_cart.cart_session_id,
    orders.order_id,
    orders.items_purchased,
    orders.price_usd
FROM sessions_seeing_cart
	INNER JOIN orders
		ON sessions_seeing_cart.cart_session_id = orders.website_session_id
;


-- first we'll look at this select statement
-- then we'll turn it into a subquery
SELECT
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    CASE WHEN cart_sessions_seeing_another_page.cart_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page,
    CASE WHEN pre_post_sessions_order.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    pre_post_sessions_order.items_purchased,
    pre_post_sessions_order.price_usd
    FROM sessions_seeing_cart
		LEFT JOIN  cart_sessions_seeing_another_page
			ON sessions_seeing_cart.cart_session_id =  cart_sessions_seeing_another_page.cart_session_id
		LEFT JOIN pre_post_sessions_order
			ON sessions_seeing_cart.cart_session_id = pre_post_sessions_order.cart_session_id
ORDER BY
	cart_session_id
;




SELECT
	time_period,
    COUNT(DISTINCT cart_session_id) AS cart_sessions,
    SUM(clicked_to_another_page) AS clickthroughs,
    SUM(clicked_to_another_page)/ COUNT(DISTINCT cart_session_id)AS cart_ctr,
    -- SUM(placed_order) AS order_placed,
    -- SUM(items_purchased) AS products_purchased,
    SUM(items_purchased)/SUM(placed_order) AS products_per_order,
    -- SUM(price_usd) AS revenue,
    SUM(price_usd)/SUM(placed_order) AS aov,
    SUM(price_usd)/COUNT(DISTINCT cart_session_id) AS rev_per_cart_session

FROM
(
SELECT
	sessions_seeing_cart.time_period,
    sessions_seeing_cart.cart_session_id,
    CASE WHEN cart_sessions_seeing_another_page.cart_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page,
    CASE WHEN pre_post_sessions_order.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    pre_post_sessions_order.items_purchased,
    pre_post_sessions_order.price_usd
    FROM sessions_seeing_cart
		LEFT JOIN  cart_sessions_seeing_another_page
			ON sessions_seeing_cart.cart_session_id =  cart_sessions_seeing_another_page.cart_session_id
		LEFT JOIN pre_post_sessions_order
			ON sessions_seeing_cart.cart_session_id = pre_post_sessions_order.cart_session_id
ORDER BY
	cart_session_id
) AS full_data

GROUP BY time_period

/* Reply from Cindy Sharp
Thanks!
It looks like the CTR from the /cart page didn't go down (I was worried), and that
 our products per order, AOV, and revenue per/cart session are all up slightly 
 since the cross-sell feature was added. 
 Doesn't look likea game changeer, but the trend looks positive. Great analysis!
 -Cindy
*/






/*Email from Cinsy sharp on Jan 12th, 2014
Good morning,
On December 12th 2013, we launched a third product targeting the birthday gift market (Birthday
bear).
Could you please run a pre-post analysis comparing the month vs. the month after, in termes of 
session-to-order-conversion rate, AOV, products per order, and revenue per session?
Thank uou!
-Cindy
*/
SELECT 
	CASE 
		WHEN website_sessions.created_at < '2013-12-12' THEN 'A. Pre_Birthday_bear'
        WHEN website_sessions.created_at >= '2013-12-12' THEN 'A. Post_Birthday_bear'
        ELSE 'UH OH... CHECK LOGIC'
	END AS time_period,
	COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate,
    
    SUM(orders.price_usd) AS total_revenue,
    SUM(orders.items_purchased) AS total_products_sold,
    SUM(orders.price_usd)/COUNT(DISTINCT orders.order_id) AS average_order_value,
    SUM(orders.items_purchased) / COUNT(DISTINCT orders.order_id) AS products_per_order,
    SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS revenue_per_session

FROM website_sessions
	LEFT JOIN orders
		ON orders.website_session_id = website_sessions.website_session_id

WHERE website_sessions.created_at BETWEEN '2013-11-12' AND '2014-01-12'
GROUP BY 1
ORDER BY time_period DESC
;

/* Reply from Cindy
Great- it looks like all of our critical metrics have improved 
since we launched the third product. This is fantastic!

I am going to meet with Tom about increasing our ad spend now that we are driving more
 revenue per session and we may also consider adding a fourth product.
 Stay tuned
 -Cindy
 */
 
 
 
 
 
 /* Email from Cindy Sharp on Oct 15th, 2014.
Subject: Quality Issues and Refunds
Good Morning,
Our Mr. fuzzy supplier had some quality issues which wern't corrected until september 2013. 
Then they had a major problem where the bears arms were falling off in Aug/Sep 2014. As a result,
 we replaced them with a new supplier on September 16, 2014. 
 Can you please pull momthly product refund rates, by product and confirm our quality 
 issues are now fixed?
 -Cindy
 
 yr,  mo,  p1_orders,  p1_refund_rt,  p2_orders,  p2_refund_rt,  p3_orders, p3_refund_rt,
 p4_orders,  p4_refund_rt
 */
 
 SELECT 
	YEAR(order_items.created_at) AS yr,
	MONTH(order_items.created_at) AS mo,
    COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_orders,
    COUNT(DISTINCT CASE WHEN order_items.product_id =1 THEN order_item_refunds.order_item_id ELSE NULL END)
    / COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_refund_rt,
    
	COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_orders,
    COUNT(DISTINCT CASE WHEN order_items.product_id =2 THEN order_item_refunds.order_item_id ELSE NULL END)
    / COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_refund_rt,
    
    COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p3_orders,
    COUNT(DISTINCT CASE WHEN order_items.product_id =3 THEN order_item_refunds.order_item_id ELSE NULL END)
    / COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p3_refund_rt,
    
    COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_orders,
    COUNT(DISTINCT CASE WHEN order_items.product_id =4 THEN order_item_refunds.order_item_id ELSE NULL END)
    / COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_refund_rt
    

 FROM order_items
	LEFT JOIN order_item_refunds
		ON order_items.order_item_id = order_item_refunds.order_item_id
WHERE order_items.created_at < '2014-10-15'
GROUP BY YEAR(order_items.created_at),
	MONTH(order_items.created_at)
;

/*
 SELECT 
	YEAR(order_items.created_at) AS yr,
	MONTH(order_items.created_at) AS mo,
	order_items.product_id,
    COUNT(DISTINCT order_item_refunds.order_item_refund_id) 
    / COUNT(DISTINCT order_items.order_item_id) AS refund_rate
 FROM order_items
	LEFT JOIN order_item_refunds
		ON order_items.order_item_id = order_item_refunds.order_item_id
WHERE order_items.created_at < '2014-10-15'
GROUP BY order_items.product_id,
	YEAR(order_items.created_at)
;
*/

/* REPLY FROM CINDY SHARP
Thanks, this is helpful to see.
Looks like the refund rates for Mr. fuzzy did go down after the
 initial improvements in September 2013, but refund rates were terrible in AUgust and 
 September, as expected (13-14%).
 
 Seems like the new supplier is doing much better so far, and the other products look okay too.
 -Cindy
*/








-- --------------------------------------------------------------------------------------------------------------------------------------------------
/* Email from Tom Parmesan On Nov 01, 2014
Subject: Repeat Visitors
Hey there,
We have been thinking about customer value based solely on their first session conversion
 and revenue. But if customers have repeat sessions, they may be more valuable than we thought.
 If that's the case, we might be able to spend a bit more to acquire them.
 
 Could you please pull data on how many of your website visitors come back for another session?
 2014 to date is good visitors come back for another session? 2014 todate is good.
 Thanks, Tom
 
 repeat sessions, users
 */
-- STEP 1: Identify the relevant new sessions. 
-- STEP 2: User the user_id values from step 1 to find any repeat sessions those users had
-- STEP 3: Analyze the data at the user level (how many sessions did each user have?) 
-- STEP 4: Aggregate the user-level analysis to generate your behavioral analysis

SELECT 
	user_id,
    website_session_id
FROM website_sessions
WHERE created_at < '2014-11-01'  -- the date of the assignment
	AND created_at >= '2014-01-01' -- prescribed date range in assignment
    AND is_repeat_session =0
;

CREATE TEMPORARY TABLE sessions_w_repeats
SELECT 
	new_sessions.user_id,
    new_sessions.website_session_id AS new_session_id,
    website_sessions.website_session_id AS repeat_session_id
FROM
(
SELECT 
	user_id,
    website_session_id
FROM website_sessions
WHERE created_at < '2014-11-01'  -- the date of the assignment
	AND created_at >= '2014-01-01' -- prescribed date range in assignment
    AND is_repeat_session =0
) AS new_sessions
	LEFT JOIN website_sessions
		ON website_sessions.user_id = new_sessions.user_id
        AND website_sessions.is_repeat_session=1 -- was a repeat session (redundant, but good to illustrate.) 
        AND website_sessions.website_session_id > new_sessions.website_session_id -- session was later but new session
        AND website_sessions.created_at < '2014-11-01' -- the date of the assignment
        AND website_sessions.created_at >= '2014-01-01' -- prescribed date range in assignment 
 ;
 
 SELECT 
	repeat_sessions,
    COUNT(DISTINCT user_id) AS users
FROM
(
SELECT
	user_id,
    COUNT(DISTINCT new_session_id) AS new_sessions,
    COUNT(DISTINCT repeat_session_id)AS repeat_sessions
FROM sessions_w_repeats
GROUP BY 1
ORDER BY 3 DESC
) AS user_level
GROUP BY 1
;

/* Reply from Tom
Thank, it's really interesting to see this breakdown.
Looks like a fair number of our customers do come back to our site after the first session. 

Seems like we should learn more about this- I'll follow up with some next steps soon.
-Tom
*/
 
 
 
 
 
 /* Email from Tom on Nov 03.2014
SUbject: Deeper dive on repeat
Ok, so the repeat session data was really interesting to see. 
Now you have got me curious to better understand the ebhavior of these repeat customers. 

Could you help me understand the minimum, maximum and average time between the first and second
session for customers who do come back? Again, analyzing 2014 to date is probably the 
right time period. 
Thanks, Tom
avg_days_first_to_second,      min_days_first_to second,     max_days_first_to_second
TIMEDIFF(second, first)
*/

-- STEP 1: iDENTIFY THE RELEVANT NEW SESSIONS
-- STEP 2: USER THE USER_ID VALUES FROM STEP 1 TO FIND ANY REPEAT SESSIONS THOSE USERS HAD
-- STEP 3: FIND THE CREATED_AT TIMES FOR FIRST AND SECOND SESSIONS
-- STEP 4: FIND THE DIIFERENCES BETWEEN FIRST AND SECOND SESSION AT A USER LEVEL
-- AGGREGATE THE USER LEVEL DATA TO FIND THE AVERAGE , MIN, MAX


CREATE TEMPORARY TABLE sessions_w_repeats_for_time_diff
SELECT 
	new_sessions.user_id,
    new_sessions.website_session_id AS new_session_id,
    new_sessions.created_at AS new_session_created_at,
    website_sessions.website_session_id AS repeat_session_id,
    website_sessions.created_at AS repeat_session_created_at
FROM
(
SELECT 
	user_id,
    website_session_id,
    created_at
FROM website_sessions
WHERE created_at >= '2014-01-01'
AND created_at < '2014-11-03'
AND is_repeat_session =0
) AS new_sessions
	LEFT JOIN website_sessions
		ON new_sessions.user_id = website_sessions.user_id
        AND website_sessions.created_at >= '2014-01-01'
        AND website_sessions.created_at < '2014-11-03'
        AND website_sessions.is_repeat_session = 1
        AND website_sessions.website_session_id > new_sessions.website_session_id
;

SELECT * FROM sessions_w_repeats_for_time_diff;



CREATE TEMPORARY TABLE users_first_to_second
SELECT 
	user_id,
    DATEDIFF(second_session_created_at, new_session_created_at) AS days_first_to_second_diff
FROM
(
SELECT 
	user_id,
    new_session_id,
    new_session_created_at,
    MIN(repeat_session_id) AS second_session_id,
    MIN(repeat_session_created_at) AS second_session_created_at
FROM  sessions_w_repeats_for_time_diff
WHERE repeat_session_id IS NOT NULL
GROUP BY user_id,
new_session_id,
new_session_created_at
) AS first_second
;

SELECT * FROM users_first_to_second;

SELECT 
	AVG(days_first_to_second_diff) AS avg_days_first_to_second,
    MIN(days_first_to_second_diff) AS min_days_first_to_second,
    MAX(days_first_to_second_diff) AS max_days_first_to_second
FROM users_first_to_second;





/*Email from Tom Parmesan on Nov 06,2014
Hi there,
Let's do a bit more digging into our repeat customers.

Can you help me understand the channels they come back through? Curious if it's all direct 
type-in, or if we are paying for these customers with paid search ads multiple times.

Comparing new vs. repeat sessions by channel would be really valuable, if you are able to 
pull it! 2014 to date is great
Thanks, Tom
*/
SELECT
	utm_source,
    utm_campaign,
    http_referer,
    COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE created_at < '2014-11-05'
AND created_at >= '2014-01-01'
GROUP BY 1,2,3
ORDER BY 5 DESC
;

SELECT
	CASE
		WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com','https://www.bsearch.com') THEN 'organic_search'
        WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
        WHEN utm_campaign = 'brand' THEN 'paid_brand'
        WHEN utm_source is NULL AND http_referer IS NULL THEN 'direct_type_in'
        WHEN utm_source = 'socialbook' THEN 'paid_social'
	END AS channel_group,
    -- utm_source,
    -- utm_campaign,
    -- utm_referer,
    COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE created_at < '2014-11-05'
AND created_at >= '2014-01-01'
GROUP BY 1
-- ORDER BY repeat_sessions DESC
;

/* Reply from Tom Parmesan on Nov 05th, 2014
Hi there,
So, it looks like when customers come back for repeat visits, thet come maily through 
organic search, direct type_in, and paid brand.

Only about 1/3 come through a paid channel, and brand clicks are cheaper than nonbrand.
So, all in all, we are not paying very much for these subsequent visits. 
This makes me wonder whether these converts to orders.. 
-Tom
*/






/* Email from Morgan Rockwell on Nov 08th,2014
Subject :Top website Pages.
Hi there!
Sounds like you and Tom have learned a lot about our repeat customers. Can I trouble 
you for one more thing?
I'd love to do a comparison of conversion rates and revenue per session for 
repeat sessionvs new sessions.

Let's continue using data from 2014, year to date.
Thank you!
-Morgan
is_repeat_session, sessions, conv_rate, rev_per_session
*/
SELECT 
website_sessions.is_repeat_session,
COUNT(DISTINCT website_sessions.website_session_id)AS sessions,

ROUND(COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id),2) AS conversion_rt,

ROUND(SUM(orders.price_usd)/COUNT(DISTINCT website_sessions.website_session_id),2) AS revenue_per_session



FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
        AND website_sessions.created_at < '2014-11-08'
        AND website_sessions.created_at >= '2014-01-01'
GROUP BY website_sessions.is_repeat_session
;


/*Reply from  Morgan.
Hey!
This is so interesting to see. Looks like repeat sessions are more likely to convert , 
and produce more revenue per sessions.
I'll circle up with Tom on this one. Since we are not paying much for repeat sessions, 
we should probably take them into account when bidding on paid traffic.
Thanks!
-Morgan
*/
