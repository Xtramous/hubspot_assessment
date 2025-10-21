--Write a query to find the total revenue and percentage of revenue by month segmented by whether or not air conditioning exists on the listing.
SELECT
    DATE_TRUNC('month', date) AS month,
    CASE 
        WHEN amenities ILIKE '%Air conditioning%' THEN 'With AC'
        ELSE 'No AC'
    END AS has_air_conditioning,
    SUM(daily_revenue) AS total_revenue,
    ROUND(
        100 * SUM(daily_revenue) 
        / SUM(SUM(daily_revenue)) OVER (PARTITION BY DATE_TRUNC('month', date)), 
        2
    ) AS pct_revenue
FROM HUBSPOT_AE_ASSESSMENT.PUBLIC_PROD.FCT_LISTING_DAILY_METRICS
GROUP BY 1, 2
ORDER BY 1, 2;
