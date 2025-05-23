{{ config(materialized='table') }}

WITH base AS (
    SELECT
        TO_DATE(inserted_at) AS snapshot_date,
        suburb,
        region,
        TRY_CAST(REGEXP_REPLACE(price_display, '[^0-9]', '') AS INT) AS price
    FROM {{ ref('stg_property_listings') }}
    WHERE price_display IS NOT NULL
)

SELECT
    snapshot_date,
    region,
    suburb,
    COUNT(*) AS total_listings,
    AVG(price) AS avg_listing_price
FROM base
GROUP BY 1, 2, 3
