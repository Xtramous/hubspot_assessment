WITH source AS (
    SELECT * FROM {{ source_ref('amenities_changelog') }}
),

cleaned AS (
    SELECT
        listing_id,
        CAST(change_at AS TIMESTAMP_NTZ) AS change_at,
        amenities
    FROM source
)

SELECT * FROM cleaned
