-- Write a variation of the maximum duration query above for listings that have 
--both a lockbox and a first aid kit listed in the amenities.

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

