{{ config(
    materialized='table',
    schema='dim'
) }}

WITH dates AS (
    SELECT
        SEQ4() AS id
    FROM TABLE(GENERATOR(ROWCOUNT => 365 * 5))  -- 生成5年日期
)

SELECT
    DATEADD(DAY, id, DATE('2020-01-01')) AS date,
    DAY(DATEADD(DAY, id, DATE('2020-01-01'))) AS day,
    MONTH(DATEADD(DAY, id, DATE('2020-01-01'))) AS month,
    TO_CHAR(DATEADD(DAY, id, DATE('2020-01-01')), 'Month') AS month_name,
    YEAR(DATEADD(DAY, id, DATE('2020-01-01'))) AS year,
    DAYOFWEEK(DATEADD(DAY, id, DATE('2020-01-01'))) AS weekday,
    TO_CHAR(DATEADD(DAY, id, DATE('2020-01-01')), 'Day') AS weekday_name,
    CASE 
        WHEN DAYOFWEEK(DATEADD(DAY, id, DATE('2020-01-01'))) IN (1, 7) THEN TRUE
        ELSE FALSE
    END AS is_weekend,
    QUARTER(DATEADD(DAY, id, DATE('2020-01-01'))) AS quarter
FROM dates
