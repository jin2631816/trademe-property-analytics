WITH source_data AS (
    SELECT *
    FROM {{ source('tm_raw', 'TRADEME_PROPERTY_LISTINGS_FULL') }}
)

, renamed_and_casted AS (
    SELECT
        -- IDs and Keys
        LISTINGID AS listing_id,         -- 使用全大写，不带引号
        MEMBERID AS member_id,           -- 使用全大写，不带引号
        REGIONID AS region_id,           -- 使用全大写，不带引号
        DISTRICTID AS district_id,         -- 使用全大写，不带引号
        SUBURBID AS suburb_id,           -- 使用全大写，不带引号
        -- 对于从 VARIANT/STRUCT 中提取的，原始 STRUCT 的键名通常是区分大小写的
        -- 所以这里保持了原始大小写并用双引号，假设 Agency 是 VARIANT 类型
        AGENCY:Id AS agency_id, -- 或者如果 Agency 本身是大写 AGENCY，则是 AGENCY:Id 或 AGENCY:"Id"

        -- Listing Details
        TITLE AS listing_title,           -- 使用全大写
        ADDRESS AS address,             -- 使用全大写
        PROPERTYTYPE AS property_type,     -- 使用全大写
        CATEGORYPATH AS category_path,   -- 使用全大写
        LISTINGGROUP AS listing_group,   -- 使用全大写
        
        -- Dates & Timestamps (原始列名也假设为全大写)
        ASAT AS as_at_str,
        STARTDATE AS start_date_str,
        ENDDATE AS end_date_str,
        NOTEDATE AS note_date_str,
        PROPERTYSALEINFORMATION:PropertyDateOfSale AS property_sale_date_str, -- VARIANT sub-field

        -- Price Information
        STARTPRICE AS start_price, 
        PRICEDISPLAY AS price_display_text,

        -- Property Attributes
        BEDROOMS AS bedrooms,
        BATHROOMS AS bathrooms,
        LOUNGES AS lounges,
        PARKING AS parking_description,
        TOTALPARKING AS total_parking_count,
        
        -- Location Attributes
        REGION AS region_name,
        DISTRICT AS district_name,
        SUBURB AS suburb_name,
        GEOGRAPHICLOCATION:Latitude AS latitude,     -- VARIANT sub-field
        GEOGRAPHICLOCATION:Longitude AS longitude,   -- VARIANT sub-field
        GEOGRAPHICLOCATION:Northing AS northing,     -- VARIANT sub-field
        GEOGRAPHICLOCATION:Easting AS easting,       -- VARIANT sub-field
        GEOGRAPHICLOCATION:Accuracy AS geo_accuracy, -- VARIANT sub-field
        
        -- Boolean Flags
        ISFEATURED AS is_featured,
        HASGALLERY AS has_gallery,
        ISBOLD AS is_bold,
        ISHIGHLIGHTED AS is_highlighted,
        ISSUPERFEATURED AS is_super_featured,
        ISCLASSIFIED AS is_classified,
        AGENCY:IsRealEstateAgency AS is_real_estate_agency, -- VARIANT sub-field

        -- Agency Details (basic)
        AGENCY:Name AS agency_name, -- VARIANT sub-field
        AGENCYREFERENCE AS agency_reference,
        
        -- Other Information
        PICTUREHREF AS picture_href,
        PHOTOURLS AS photo_urls_array, 
        OPENHOMES AS open_homes_array, 
        ADDITIONALDATA:BulletPoints AS bullet_points_array, -- VARIANT sub-field
        ADDITIONALDATA:Tags AS tags_array,               -- VARIANT sub-field
        LISTINGEXTRAS AS listing_extras_array,
        ADJACENTSUBURBIDS AS adjacent_suburb_ids_array,
        ADJACENTSUBURBNAMES AS adjacent_suburb_names_array,
        RESERVESTATE AS reserve_state,
        LISTINGLENGTH AS listing_length, 
        LISTINGPLATFORM AS listing_platform,
        PREMIUMPACKAGECODE AS premium_package_code,
        ADJACENTSUBURBNAMES:PropertySaleType AS property_sale_type, -- VARIANT sub-field

        -- Timestamps from ETL
        etl_inserted_at_utc -- 这个列名是你自己加的，假设它是小写下划线

    FROM source_data
)

, date_conversions AS (
    SELECT
        *,
        -- Helper function to convert epoch seconds to timestamp, handling NULLs
        -- This isn't standard SQL but a concept. We'll do it inline.

        -- AsAt conversion
        TO_TIMESTAMP_NTZ(TRY_CAST(REGEXP_SUBSTR(as_at_str, '\\((\\d+)', 1, 1, 'e') AS BIGINT) / 1000) AS as_at_timestamp,

        -- StartDate conversion
        TO_TIMESTAMP_NTZ(TRY_CAST(REGEXP_SUBSTR(start_date_str, '\\((\\d+)', 1, 1, 'e') AS BIGINT) / 1000) AS start_timestamp,

        -- EndDate conversion
        TO_TIMESTAMP_NTZ(TRY_CAST(REGEXP_SUBSTR(end_date_str, '\\((\\d+)', 1, 1, 'e') AS BIGINT) / 1000) AS end_timestamp,

        -- NoteDate conversion (often /Date(0)/)
        CASE 
            WHEN TRY_CAST(REGEXP_SUBSTR(note_date_str, '\\((\\d+)', 1, 1, 'e') AS BIGINT) / 1000 = 0 THEN NULL -- Treat /Date(0)/ as NULL
            ELSE TO_TIMESTAMP_NTZ(TRY_CAST(REGEXP_SUBSTR(note_date_str, '\\((\\d+)', 1, 1, 'e') AS BIGINT) / 1000)
        END AS note_timestamp,
        
        -- PropertySaleDate conversion
        TO_TIMESTAMP_NTZ(TRY_CAST(REGEXP_SUBSTR(property_sale_date_str, '\\((\\d+)', 1, 1, 'e') AS BIGINT) / 1000) AS property_sale_timestamp

    FROM renamed_and_casted
)

-- Final selection of columns for the staging model
SELECT 
    listing_id,
    member_id,
    region_id,
    district_id,
    suburb_id,
    agency_id,
    listing_title,
    address,
    property_type,
    category_path,
    listing_group,
    
    as_at_timestamp, -- Converted timestamp
    start_timestamp, -- Converted timestamp
    end_timestamp,   -- Converted timestamp
    note_timestamp,  -- Converted timestamp
    property_sale_timestamp, -- Converted timestamp
    
    CAST(start_price AS DECIMAL(18,2)) as start_price,
    TRY_CAST(REGEXP_REPLACE(price_display_text, '[^0-9]', '') AS INT) AS price_display_text,
    
    TRY_CAST(bedrooms AS INTEGER) as bedrooms,
    TRY_CAST(bathrooms AS INTEGER) as bathrooms,
    TRY_CAST(lounges AS INTEGER) as lounges,
    parking_description,
    TRY_CAST(total_parking_count AS INTEGER) as total_parking_count,
    
    region_name,
    district_name,
    suburb_name,
    latitude,
    longitude,
    northing,
    easting,
    geo_accuracy,
    
    is_featured,
    has_gallery,
    is_bold,
    is_highlighted,
    is_super_featured,
    is_classified,
    is_real_estate_agency,
    
    agency_name,
    agency_reference,
    
    picture_href,
    photo_urls_array, 
    open_homes_array, 
    bullet_points_array,
    tags_array,
    listing_extras_array,
    adjacent_suburb_ids_array,
    adjacent_suburb_names_array,
    
    reserve_state,
    listing_length, -- Will be NULL if original was NULL
    listing_platform,
    premium_package_code,
    property_sale_type,

    etl_inserted_at_utc

FROM date_conversions
