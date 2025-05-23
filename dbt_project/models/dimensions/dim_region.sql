{{ config(materialized='table') }}

SELECT DISTINCT
    suburb,
    region
FROM {{ ref('stg_property_listings') }}
WHERE suburb IS NOT NULL
  AND region IS NOT NULL
