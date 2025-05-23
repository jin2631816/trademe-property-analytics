{{ config(
    materialized='table',
    schema='dim'
) }}

SELECT DISTINCT
    property_type
FROM {{ ref('stg_property_listings') }}
WHERE property_type IS NOT NULL
