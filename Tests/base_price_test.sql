-- This test ensures no listing has an unrealistic base price

WITH base_price_test AS (
    SELECT
        listing_id,
        MAX(base_price) AS base_price
    FROM {{ ref('fct_listing_daily_metrics') }}
    GROUP BY listing_id
)
SELECT
    listing_id,
    base_price
FROM base_price_test
WHERE base_price > 100000
