{{ config(
    materialized='table'
) }}

WITH listings AS (
    SELECT
        listing_id,
        listing_name,
        host_id,
        host_name,
        {{ column_cleaner('neighborhood') }} AS neighborhood,
        property_type,
        room_type,
        accommodates,
        {{ format_price('price') }} AS base_price,
        number_of_reviews,
        {{ null_handler('review_scores_rating', 0) }} AS review_score_rating,
        amenities
    FROM {{ source_ref('stg_listings') }}
),

reviews AS (
    SELECT * FROM {{ source_ref('int_reviews_with_scores') }}
),

latest_amenities AS (
    SELECT
        listing_id,
        amenities,
        change_at
    FROM (
        SELECT
            listing_id,
            amenities,
            change_at,
            ROW_NUMBER() OVER (PARTITION BY listing_id ORDER BY change_at DESC) AS rn
        FROM {{ source_ref('stg_amenities_changelog') }}
    )
    WHERE rn = 1
)

SELECT
    l.listing_id,
    l.listing_name,
    l.neighborhood,
    l.property_type,
    l.room_type,
    l.accommodates,
    l.base_price,
    l.review_score_rating,
    {{ null_handler('r.avg_review_score', 0) }} AS avg_review_score,
    {{ null_handler('r.total_reviews', 0) }} AS total_reviews,
    la.amenities,
    la.change_at AS last_amenities_update
FROM listings l
LEFT JOIN reviews r ON l.listing_id = r.listing_id
LEFT JOIN latest_amenities la ON l.listing_id = la.listing_id
