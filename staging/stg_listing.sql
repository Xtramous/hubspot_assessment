WITH source AS (
    SELECT * FROM {{ source_ref('listings') }}
),

cleaned AS (
    SELECT
        id AS listing_id,
        name AS listing_name,
        host_id,
        host_name,
        {{ date_cast('host_since') }} AS host_since,
        {{ column_cleaner('neighborhood') }} AS neighborhood,
        property_type,
        room_type,
        accommodates,
        {{ format_price('price') }} AS price,
        number_of_reviews,
        {{ date_cast('first_review') }} AS first_review_date,
        {{ date_cast('last_review') }}  AS last_review_date,
        {{ null_handler('review_scores_rating', 0) }} AS review_scores_rating,
        amenities
    FROM source
)

SELECT * FROM cleaned
