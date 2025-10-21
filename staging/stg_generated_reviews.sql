WITH source AS (
    SELECT * FROM {{ source_ref('generated_reviews') }}
),

cleaned AS (
    SELECT
        id AS review_id,
        listing_id,
        review_score,
        {{ date_cast('review_date') }} AS review_date
    FROM source
)

SELECT * FROM cleaned
