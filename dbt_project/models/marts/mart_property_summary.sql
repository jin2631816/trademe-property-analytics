{{ config(
    materialized='table',
    schema='mart'
) }}

SELECT
    listing_id,
    category,
    title,
    TRY_CAST(REGEXP_REPLACE(price_display, '[^0-9]', '') AS INT) AS price,
    start_price,
    is_new,
    regionid,
    region,
    suburbid,
    suburb,
    bedrooms ,
    bathrooms ,
    lounges ,
    land_area ,
    property_type,
    geolocation_lat,
    geolocation_lng ,
    LISTING_GROUP,
    INSERTED_AT
FROM {{ ref('stg_property_listings') }}
WHERE listing_id IS NOT NULL
