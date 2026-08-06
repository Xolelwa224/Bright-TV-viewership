-- Databricks notebook source
USE brightlearn2.data2;

-- COMMAND ----------

--- View the entire table
SELECT *
FROM bright_tv_viewership
LIMIT 100;

---Check the table structure
DESCRIBE bright_tv_viewership;

---Investigating the two User ID columns
SELECT
    UserID0,
    userid4
FROM bright_tv_viewership
LIMIT 100;

--- Checking whether the two user IDs are actually different.

SELECT COUNT(*) AS different_user_ids
FROM bright_tv_viewership
WHERE UserID0 <> userid4;


---Checking  which one is missing
---This will help me to determine whether one column is simply a duplicate of the other.
SELECT
    COUNT(*) AS total_rows,
    COUNT(UserID0) AS userid_capital_count,
    COUNT(userid4) AS userid_lowercase_count
FROM bright_tv_viewership;


--- Checking whether the two columns contain the same IDs
SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN UserID0 = userid4
            THEN 1
            ELSE 0
        END
    ) AS same_user_id,
    SUM(
        CASE
            WHEN UserID0 <> userid4
            THEN 1
            ELSE 0
        END
    ) AS different_user_id
FROM bright_tv_viewership;


--- Checking if they're truly different values
--- This query only returns rows where both IDs exist but are different:
SELECT
    UserID0,
    userid4,
    Channel2,
    RecordDate2
FROM bright_tv_viewership
WHERE UserID0 IS NOT NULL
AND userid4 IS NOT NULL
AND UserID0 <> userid4;

 --- Merging the two columns  

SELECT
    COALESCE(UserID0, userid4) AS User_ID,
    *
FROM bright_tv_viewership;

--- Check whether the merged column has missing values
SELECT
    COUNT(*) AS Total,
    COUNT(
        COALESCE(UserID0, userid4)
    ) AS Clean_UserID
FROM bright_tv_viewership;


--- Check duplicates

SELECT
    COALESCE(UserID0, userid4) AS User_ID,
    COUNT(*) AS duplicate_count
FROM bright_tv_viewership
GROUP BY COALESCE(UserID0, userid4)
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


SELECT
    COALESCE(UserID0, userid4) AS User_ID,
    Channel2,
    RecordDate2,
    `Duration 2`,
    COUNT(*) AS duplicate_count
FROM bright_tv_viewership
GROUP BY
    COALESCE(UserID0, userid4),
    Channel2,
    RecordDate2,
    `Duration 2`
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


--- Create a cleaned table without duplicates
CREATE OR REPLACE TEMP VIEW viewership_clean AS
WITH duplicates_removed AS
(
    SELECT
        *,
        COALESCE(UserID0, userid4) AS User_ID,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                COALESCE(UserID0, userid4),
                Channel2,
                RecordDate2,
                `Duration 2`
            ORDER BY RecordDate2 DESC
        ) AS rn

    FROM bright_tv_viewership
)

SELECT
    User_ID,
    Channel2,
    RecordDate2,
    `Duration 2`
FROM duplicates_removed
WHERE rn = 1;


--- Viewing the cleaned table 
SELECT *
FROM viewership_clean
LIMIT 20;


--- Clean the dates
SELECT
    RecordDate2,
    TO_DATE(RecordDate2) AS watch_date
FROM viewership_clean
LIMIT 20;


--- Extract the day name
SELECT 
    TO_DATE(RecordDate2) AS watch_date,
    DAYNAME(TO_DATE(RecordDate2)) AS day_name
FROM viewership_clean
LIMIT 20;

--- Extract the month
SELECT
    TO_DATE(RecordDate2) AS watch_date,
    MONTHNAME(TO_DATE(RecordDate2)) AS month_name
FROM viewership_clean
LIMIT 20;


--- Classify weekdays and weekends
SELECT
DAYNAME(RecordDate2) AS day_name,

CASE
    WHEN DAYNAME(RecordDate2) IN ('Sat', 'Sun') THEN 'Weekend'
    ELSE 'Weekday'
END AS day_classification
FROM viewership_clean;

--- Format the time
SELECT

    DATE_FORMAT(RecordDate2,'HH:mm:ss') AS watch_time

FROM viewership_clean
LIMIT 20;

---cleaning channel 
SELECT

CASE
        WHEN Channel2 IN ('SawSee', 'Sawsee')
            THEN 'SawSee'

        WHEN Channel2 IN (
            'SuperSport Live Events',
            'Live on SuperSport',
            'Supersport Live Events',
            'DSTv Events 1'
        )
            THEN 'Live Events'

        ELSE Channel2
    END AS tv_channel,
FROM viewership_clean;

--- Time of Day
SELECT

DATE_FORMAT(RecordDate2,'HH:mm:ss') AS watch_time,

CASE

WHEN DATE_FORMAT(RecordDate2,'HH:mm:ss')
BETWEEN '00:00:00' AND '05:59:59'
THEN 'Midnight'

WHEN DATE_FORMAT(RecordDate2,'HH:mm:ss')
BETWEEN '06:00:00' AND '11:59:59'
THEN 'Morning'

WHEN DATE_FORMAT(RecordDate2,'HH:mm:ss')
BETWEEN '12:00:00' AND '16:59:59'
THEN 'Afternoon'

ELSE 'Evening'

END AS Time_of_Day

FROM viewership_clean
LIMIT 20;


--- Duration Bucket

SELECT

`Duration 2`,

CASE

WHEN `Duration 2`
BETWEEN '00:00:00'
AND '00:30:00'

THEN 'Low Usage'

WHEN `Duration 2`
BETWEEN '00:30:01'
AND '00:59:59'

THEN 'Medium Usage'

ELSE 'High Usage'

END AS Duration_Bucket

FROM viewership_clean
LIMIT 20;






--- Big query 
SELECT
COALESCE(UserID0,userid4) AS User_ID,

TO_DATE(RecordDate2) AS Watch_Date,

DAYNAME(TO_DATE(RecordDate2)) AS Day_Name,

MONTHNAME(TO_DATE(RecordDate2)) AS Month_Name,

DATE_FORMAT(RecordDate2,'HH:mm:ss') AS Watch_Time,

    CASE
        WHEN DAYNAME(RecordDate2) IN ('Sat', 'Sun')
            THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_classification,


    CASE
        WHEN Channel2 IN ('SawSee', 'Sawsee')
            THEN 'SawSee'

        WHEN Channel2 IN (
            'SuperSport Live Events',
            'Live on SuperSport',
            'Supersport Live Events',
            'DSTv Events 1'
        )
            THEN 'Live Events'

        ELSE Channel2
    END AS tv_channel,

    DATE_FORMAT(RecordDate2, 'HH:mm:ss') AS watch_time,

    CASE
        WHEN DATE_FORMAT(RecordDate2, 'HH:mm:ss')
            BETWEEN '00:00:00' AND '05:59:59'
            THEN '01. Midnight'

        WHEN DATE_FORMAT(RecordDate2, 'HH:mm:ss')
            BETWEEN '06:00:00' AND '11:59:59'
            THEN '02. Morning'

        WHEN DATE_FORMAT(RecordDate2, 'HH:mm:ss')
            BETWEEN '12:00:00' AND '16:59:59'
            THEN '03. Afternoon'

        ELSE '04. Evening'
    END AS time_of_day,

    DATE_FORMAT(`Duration 2`, 'HH:mm:ss') AS duration,

    CASE
        WHEN `Duration 2` BETWEEN '00:05:00' AND '00:30:00'
            THEN '01. Low Usage'

        WHEN `Duration 2` BETWEEN '00:30:01' AND '00:59:59'
            THEN '02. Medium Usage'

        WHEN `Duration 2` > '00:59:59'
            THEN '03. High Usage'

        ELSE '04. No Usage'
    END AS screen_time_bucket,

    HOUR(RecordDate2) AS hour_of_day

FROM bright_tv_viewership;
















