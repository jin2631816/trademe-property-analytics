{{ config(materialized='view') }}

WITH source_data AS (
    SELECT 
        listing_id,
        title,
        price_display,
        suburb,
        region,
        bedrooms,
        bathrooms,
        land_area,
        listing_date,
        inserted_at
    FROM {{ source('raw', 'trademe_property_listings') }}
)

SELECT
    listing_id,
    title,
    price_display,
    suburb,
    region,
    TRY_CAST(bedrooms AS INT) AS bedrooms,
    TRY_CAST(bathrooms AS INT) AS bathrooms,
    TRY_CAST(land_area AS DOUBLE) AS land_area,
    listing_date,
    inserted_at
FROM source_data
