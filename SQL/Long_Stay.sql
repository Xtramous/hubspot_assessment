--Write a query to find the maximum duration one could stay in each of these listings, 
--based on the availability and what the owner allows.

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
