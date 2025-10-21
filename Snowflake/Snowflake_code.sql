CREATE WAREHOUSE IF NOT EXISTS COMPUTE_HS
  WITH WAREHOUSE_SIZE = 'XSMALL'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  INITIALLY_SUSPENDED = TRUE;

  CREATE DATABASE IF NOT EXISTS SEED;
  CREATE DATABASE IF NOT EXISTS INTERMEDIATE;
  CREATE DATABASE IF NOT EXISTS STAGE;
  CREATE SCHEMA IF NOT EXISTS HUBSPOT_AE_ASSESSMENT.PUBLIC;


----------All sql codes
--- Ques 1 --Monthly revenue by Air Conditioning

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


--2 -- Average price increase per neighborhood

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

-- 3 long stay

WITH ordered AS (
    SELECT
        listing_id,
        date,
        maximum_nights,
        is_available,
        ROW_NUMBER() OVER (PARTITION BY listing_id ORDER BY date) AS rn
    FROM HUBSPOT_AE_ASSESSMENT.PUBLIC_PROD.FCT_LISTING_DAILY_METRICS
),

-- Only keep available days and calculate "gap" to detect streaks
available AS (
    SELECT
        listing_id,
        date,
        maximum_nights,
        rn,
        ROW_NUMBER() OVER (PARTITION BY listing_id ORDER BY date) - rn AS streak_grp
    FROM ordered
    WHERE is_available = 1
),

-- Count streak lengths
streaks AS (
    SELECT
        listing_id,
        MIN(date) AS start_date,
        MAX(date) AS end_date,
        COUNT(*) AS streak_length,
        MAX(maximum_nights) AS max_allowed
    FROM available
    GROUP BY listing_id, streak_grp
),

-- Cap each streak by maximum_nights
streaks_capped AS (
    SELECT
        listing_id,
        LEAST(streak_length, max_allowed) AS max_possible_stay
    FROM streaks
),

-- Get the longest possible stay per listing
listing_max_stay AS (
    SELECT
        listing_id,
        MAX(max_possible_stay) AS max_possible_stay
    FROM streaks_capped
    GROUP BY listing_id
)

SELECT *
FROM listing_max_stay
ORDER BY listing_id;


-- 4 lockbox

WITH filtered_listings AS (
    -- Keep only listings that have both lockbox and first aid kit in amenities
    SELECT *
    FROM HUBSPOT_AE_ASSESSMENT.PUBLIC_PROD.FCT_LISTING_DAILY_METRICS
    WHERE LOWER(amenities) ILIKE '%lockbox%'
      AND LOWER(amenities) ILIKE '%first aid kit%'
),

ordered AS (
    SELECT
        listing_id,
        date,
        maximum_nights,
        is_available,
        ROW_NUMBER() OVER (PARTITION BY listing_id ORDER BY date) AS rn
    FROM filtered_listings
),

-- Only keep available days and detect streaks
available AS (
    SELECT
        listing_id,
        date,
        maximum_nights,
        rn,
        ROW_NUMBER() OVER (PARTITION BY listing_id ORDER BY date) - rn AS streak_grp
    FROM ordered
    WHERE is_available = 1
),

-- Count streak lengths per listing
streaks AS (
    SELECT
        listing_id,
        MIN(date) AS start_date,
        MAX(date) AS end_date,
        COUNT(*) AS streak_length,
        MAX(maximum_nights) AS max_allowed
    FROM available
    GROUP BY listing_id, streak_grp
),

-- Cap each streak by maximum_nights
streaks_capped AS (
    SELECT
        listing_id,
        LEAST(streak_length, max_allowed) AS max_possible_stay
    FROM streaks
),

-- Maximum stay per listing
listing_max_stay AS (
    SELECT
        listing_id,
        MAX(max_possible_stay) AS max_possible_stay
    FROM streaks_capped
    GROUP BY listing_id
)

-- Return max possible stay for all filtered listings
SELECT *
FROM listing_max_stay
ORDER BY listing_id;


