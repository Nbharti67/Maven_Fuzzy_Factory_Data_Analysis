/* Email from Cindy Sharp on Nov 27, 2012
Subject : Board meeting Next Week

Good Morning,
I need some help preparing a presentation of our growth story over our first 8 months. 
This will also be a good excuse to show off our analytical capabilities a bit.
-Cindy
*/
/*
Tell the story of your company's growth, using trended performance data.
Use the database to explain some of the details around your growth story, and quantify 
the revenue impact of some of your wins
Analyze current performance, and use the data  available to assess 
upcoming opportunities. 
*/
/*
1. Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for 
gsearch sessions and orders so that we can showcase the growth there?
*/
USE mavenfuzzyfactory;

SELECT 
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source ='gsearch'
AND website_sessions.created_at <'2012-11-27'
GROUP BY YEAR(website_sessions.created_at),
    MONTH(website_sessions.created_at)
;
/*
2. Next, it would be great to see a similar monthly trend for gsearch, but this time splitting
out nonbrand and brand campaigns separately. I am wondering if brand is picking up at all. 
If so, this is a good story to tell
*/
SELECT 
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(CASE WHEN website_sessions.utm_campaign='nonbrand' THEN website_sessions.website_session_id ELSE NULL END) AS 'nonbrand_sessions',
    COUNT(CASE WHEN website_sessions.utm_campaign='nonbrand' THEN orders.order_id ELSE NULL END ) AS 'nonbrand_orders',
    
    COUNT(CASE WHEN website_sessions.utm_campaign='brand' THEN website_sessions.website_session_id ELSE NULL END) AS 'brand_sessions',
    COUNT(CASE WHEN website_sessions.utm_campaign='brand' THEN orders.order_id ELSE NULL END ) AS 'brand_orders'
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source ='gsearch'
AND website_sessions.created_at <'2012-11-27'
GROUP BY YEAR(website_sessions.created_at),
    MONTH(website_sessions.created_at)
;

/*
3. While we are on gsearch, could you dive into nonbrand, and pull monthly sessions and orders
split by device type? I want to flex our analytical muscles a little and show the board we 
really know our traffic sources.
*/
SELECT 
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type ='desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type='desktop' THEN orders.order_id ELSE NULL END) AS desktop_orders,
    
    COUNT(DISTINCT CASE WHEN website_sessions.device_type ='mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN website_sessions.device_type='mobile' THEN orders.order_id ELSE NULL END) AS mobile_orders
    
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.utm_source ='gsearch'
AND website_sessions.utm_campaign = 'nonbrand'
AND website_sessions.created_at <'2012-11-27'
GROUP BY YEAR(website_sessions.created_at),
    MONTH(website_sessions.created_at)
;

/*
4. I am worried that one of our more pessimistic board members may be concenrned about the 
larget % of traffic from gsearch. Can you pull monthly trends for gsearch, alongside 
monthly trends for each of our other channels.
*/
SELECT utm_source,
	utm_campaign,
    http_referer
FROM website_sessions
WHERE created_at<'2012-11-27'
GROUP BY utm_source
;

SELECT
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(CASE WHEN utm_source='gsearch' THEN website_sessions.website_session_id ELSE NULL END) AS 'gsearch_paid_sessions',
    COUNT(CASE WHEN utm_source='bsearch' THEN website_sessions.website_session_id ELSE NULL END) AS 'bsearch_paid_sessions',
    COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) AS 'organic_search_sessions',
    COUNT(CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) AS 'direct_typein_sessions'
    
FROM website_sessions
	-- LEFT JOIN orders
		-- ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at <'2012-11-27'
GROUP BY 1,2
;


/*
5. I'd like to tell the story of our website performance improvements over the course of the 
first 8 months. Could you pull session to order conversion rates, by month?
*/
SELECT 
	YEAR(website_sessions.created_at) AS yr,
    MONTH(website_sessions.created_at) AS mo,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS cvr_rate
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2012-11-27'
GROUP BY 1,2
;


/*6. For the gsearch lander test, please estimate the revenue that test earned us
(Hint: Look at the increase CVR from the test (Jun 19-Jul 28), and use nonbrand sessions 
and revenue since then to calculate incremental values.
*/
SELECT 
	MIN(website_pageview_id) AS min_pv_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
;

CREATE TEMPORARY TABLE first_pageviews
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pv_id
FROM website_pageviews
	INNER JOIN website_sessions
		ON website_pageviews.website_session_id= website_sessions.website_session_id
        AND website_sessions.created_at < '2012-07-28'
        AND website_sessions.utm_source ='gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
        AND website_pageviews.website_pageview_id >= 23504
GROUP BY website_pageviews.website_session_id
;


CREATE TEMPORARY TABLE sessions_w_landing_page
SELECT 
	first_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM first_pageviews
	LEFT JOIN website_pageviews
		ON first_pageviews.min_pv_id = website_pageviews.website_pageview_id
;
SELECT DISTINCT landing_page FROM sessions_w_landing_page;

CREATE TEMPORARY TABLE sessions_w_orders
SELECT 
	sessions_w_landing_page.website_session_id,
    sessions_w_landing_page.landing_page,
    orders.order_id
FROM sessions_w_landing_page
	LEFT JOIN orders
		ON sessions_w_landing_page.website_session_id = orders.website_session_id
;


SELECT 
landing_page,
COUNT(DISTINCT website_session_id) AS sessions,
COUNT(DISTINCT order_id) AS orders,
COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS conv_rate
FROM sessions_w_orders
GROUP BY landing_page
;


SELECT 
	MAX(website_sessions.website_session_id) AS max_Home_session_id
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
	
    WHERE website_sessions.created_at < '2012-11-27'
        AND pageview_url ='/home'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
;

SELECT 
	COUNT(website_session_id) AS session_since_test
FROM website_sessions
WHERE created_at <'2012-11-27'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND website_session_id > 17145
;
-- 22,972 website sessions since the test

-- X .0087 incremental conversion = 202 incremental orders since 7/29
	-- roughly 4 months, so roughly 50 extra orders per month. Not bad!

/*
7. For the landing page test you analyzed previously, it would be great to show a full 
conversion funnel from each of the two pages to orders. You can use the same time period you analyzed
last time (June 19- Jul28)
*/
/* /home, /products, /the-original-mr-fuzzy, /cart, /shipping,/billing, /thank-you-for-your-order
/lander-1
*/
USE mavenfuzzyfactory;
SELECT DISTINCT pageview_url
FROM website_pageviews;

CREATE TEMPORARY TABLE session_level_made_it
SELECT 
	website_session_id,
	MAX(home_page) AS saw_home_page,
    MAX(lander1_page) AS saw_lander1_page,
    MAX(products_page) AS saw_products_page,
    MAX(mr_fuzzy_page) AS saw_mr_fuzzy_page,
    MAX(cart_page) AS saw_cart_page,
    MAX(shipping_page) AS saw_shipping_page,
    MAX(billing_page) AS saw_billing_page,
    MAX(thankyou_page) AS saw_thankyou_page
FROM
(
SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url,
    website_pageviews.created_at,
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS home_page,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander1_page,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions
	LEFT JOIN website_pageviews
		ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE 
-- website_pageviews.pageview_url IN ('/home','/lander-1', '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
 website_sessions.created_at < '2012-07-28'
AND website_sessions.created_at >'2012-07-19'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
ORDER BY 
	website_sessions.website_session_id,
    website_pageviews.created_at
) AS pageview_level
GROUP BY website_session_id
;
SELECT * FROM session_level_made_it;
SELECT 
	CASE 
		WHEN saw_home_page = 1 THEN 'saw_homepage'
        WHEN saw_lander1_page = 1 THEN 'saw_lander1_page'
	END AS segments,
    COUNT(website_session_id) AS sessions,
    COUNT(CASE WHEN saw_products_page =1 THEN website_session_id ELSE NULL END) AS to_products,
    COUNT(CASE WHEN saw_mr_fuzzy_page =1 THEN website_session_id ELSE NULL END) AS to_mr_fuzzy,
    COUNT(CASE WHEN saw_cart_page =1 THEN website_session_id ELSE NULL END) AS to_cart,
    COUNT(CASE WHEN saw_shipping_page =1 THEN website_session_id ELSE NULL END) AS to_shipping,
    COUNT(CASE WHEN saw_billing_page =1 THEN website_session_id ELSE NULL END) AS to_billing,
    COUNT(CASE WHEN saw_thankyou_page =1 THEN website_session_id ELSE NULL END) AS to_thank_you
FROM session_level_made_it
GROUP BY segments
;


SELECT 
	CASE 
		WHEN saw_home_page = 1 THEN 'saw_homepage'
        WHEN saw_lander1_page = 1 THEN 'saw_lander1_page'
	END AS segments,
    COUNT(website_session_id) AS sessions,
    COUNT(CASE WHEN saw_products_page =1 THEN website_session_id ELSE NULL END)/ COUNT(website_session_id)  AS lander_clickthrough_rt,
    COUNT(CASE WHEN saw_mr_fuzzy_page =1 THEN website_session_id ELSE NULL END) /COUNT(CASE WHEN saw_products_page =1 THEN website_session_id ELSE NULL END)  AS product_clickthrough_rate,
    COUNT(CASE WHEN saw_cart_page =1 THEN website_session_id ELSE NULL END)/COUNT(CASE WHEN saw_mr_fuzzy_page =1 THEN website_session_id ELSE NULL END) AS mr_fuzzy_clickthrough_rate,
    COUNT(CASE WHEN saw_shipping_page =1 THEN website_session_id ELSE NULL END)/ COUNT(CASE WHEN saw_cart_page =1 THEN website_session_id ELSE NULL END) AS cart_clickthrough_rt,
    COUNT(CASE WHEN saw_billing_page =1 THEN website_session_id ELSE NULL END) / COUNT(CASE WHEN saw_shipping_page =1 THEN website_session_id ELSE NULL END) AS shipping_clickthrough_rt,
    COUNT(CASE WHEN saw_thankyou_page =1 THEN website_session_id ELSE NULL END)/ COUNT(CASE WHEN saw_billing_page =1 THEN website_session_id ELSE NULL END)  AS billing_clickthrough_rate
FROM session_level_made_it
GROUP BY segments
;
/*
8. I'd love for you to quantify the impact of pur billing test, as well. Please analyze
 the lift generated from the test (sep 10- Nov 10), in terms of revenue per billing 
 page session, and then pull the number of billing page sessions for the past month to 
 understand monthly impact.
 revenue per billing page session, 
 */
 
SELECT 
	session_level_made_it.website_session_id,
    COUNT(CASE WHEN saw_billing_page =1 THEN session_level_made_it.website_session_id ELSE NULL END) AS billing_page_session,
    SUM(orders.price_usd) AS revenue,
    SUM(orders.price_usd) / COUNT(CASE WHEN saw_billing_page =1 THEN session_level_made_it.website_session_id ELSE NULL END)  AS revenue_per_billing_page_session
FROM session_level_made_it
	LEFT JOIN orders
		ON orders.website_session_id = session_level_made_it.website_session_id
;

