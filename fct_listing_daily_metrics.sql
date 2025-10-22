{{ config(
    materialized='table'
) }}
WITH calendar AS (
    SELECT
        listing_id,
        {{ date_cast('date') }} AS date,
        CASE WHEN available = 't' THEN 1 ELSE 0 END AS is_available,
        CASE WHEN available = 'f' THEN 1 ELSE 0 END AS is_booked,
        {{ format_price('price') }} AS daily_price,
        reservation_id,
        minimum_nights,
        maximum_nights
    FROM {{ source_ref('stg_calendar') }}
),

listings AS (
    SELECT * FROM {{ source_ref('int_listings_enriched') }}
),

joined AS (
    SELECT
        c.listing_id,
        c.date,
        {{ column_cleaner('l.neighborhood') }} AS neighborhood,
        l.property_type,
        l.room_type,
        l.accommodates,
        {{ null_handler('l.base_price', 0) }} AS base_price,
        {{ null_handler('c.daily_price', 0) }} AS daily_price,
        c.is_available,
        c.is_booked,
        CASE 
            WHEN c.is_booked = 1 THEN c.daily_price 
            ELSE 0 
        END AS daily_revenue,
        {{ null_handler('l.review_score_rating', 0) }} AS review_score_rating,
        {{ null_handler('l.avg_review_score', 0) }} AS avg_review_score,
        {{ null_handler('l.total_reviews', 0) }} AS total_reviews,
        l.amenities,
        l.last_amenities_update,
        {{ safe_divide('c.is_booked', '1') }} AS occupancy_ratio,
        c.maximum_nights,
        c.minimum_nights
    FROM calendar c
    LEFT JOIN listings l
        ON c.listing_id = l.listing_id
)

SELECT * FROM joined
