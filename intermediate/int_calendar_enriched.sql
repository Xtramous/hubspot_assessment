WITH calendar AS (
    SELECT
        listing_id,
        {{ date_cast('date') }} AS date,
        CASE WHEN available = 't' THEN TRUE ELSE FALSE END AS is_available,
        CASE WHEN reservation_id IS NOT NULL THEN TRUE ELSE FALSE END AS is_reserved,
        {{ format_price('price') }} AS daily_price,
        minimum_nights,
        maximum_nights
    FROM {{ source_ref('stg_calendar') }}
)

SELECT
    listing_id,
    date,
    is_available,
    is_reserved,
    daily_price,
    minimum_nights,
    maximum_nights
FROM calendar
