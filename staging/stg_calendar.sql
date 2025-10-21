WITH source AS (
    SELECT * FROM {{ source_ref('calendar') }}
),

cleaned AS (
    SELECT
        listing_id,
        {{ date_cast('date') }} AS date,
        CASE WHEN available = 't' THEN TRUE ELSE FALSE END AS available,
        reservation_id,
        {{ format_price('price') }} AS price,
        minimum_nights,
        maximum_nights
    FROM source
)

SELECT * FROM cleaned
