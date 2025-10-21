-- Write a query to find the average price increase for each neighborhood from July 12th 2021 to July 11th 2022.
WITH price_by_listing AS (
    SELECT
        listing_id,
        neighborhood,
        MAX(CASE WHEN date = '2021-07-12' THEN daily_price END) AS price_start,
        MAX(CASE WHEN date = '2022-07-11' THEN daily_price END) AS price_end
    FROM HUBSPOT_AE_ASSESSMENT.PUBLIC_PROD.FCT_LISTING_DAILY_METRICS
    GROUP BY listing_id, neighborhood
)
SELECT
    neighborhood,
    ROUND(AVG(price_end - price_start), 2) AS avg_price_increase
FROM price_by_listing
GROUP BY neighborhood
ORDER BY neighborhood;
