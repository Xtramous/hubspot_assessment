WITH reviews AS (
    SELECT
        listing_id,
        COUNT(*) AS total_reviews,
        AVG(review_score) AS avg_review_score
    FROM {{ source_ref('stg_generated_reviews') }}
    GROUP BY listing_id
)

SELECT
    listing_id,
    total_reviews,
    {{ null_handler('avg_review_score', 0) }} AS avg_review_score
FROM reviews
