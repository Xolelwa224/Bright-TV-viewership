-- Databricks notebook source
USE brightlearn2.data2;
USE brightlearn2.data2;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC

-- COMMAND ----------

CREATE OR REPLACE TEMPORARY TABLE USER_PROFILE AS  
SELECT 
      UserID,
     CASE
         WHEN Province IS NULL OR TRIM(Province)='' OR LOWER(Province)='none'
         THEN 'Uncategorized'
         ELSE INITCAP(TRIM(Province))
     END AS region,

     CASE
         WHEN Gender IS NULL OR TRIM(Gender)='' OR LOWER(Gender)='none'
         THEN 'Unknown'
         ELSE INITCAP(TRIM(Gender))
     END AS Sex,

     CASE
         WHEN Race IS NULL OR TRIM(Race)='' OR LOWER(Race) IN ('none','other')
         THEN 'Unknown'
         ELSE INITCAP(TRIM(race))
     END AS Ethnicity,



     CASE
         WHEN Age < 13 THEN 'Kids'
         WHEN Age BETWEEN 13 AND 17 THEN 'Youth'
         WHEN Age BETWEEN 18 AND 35 THEN 'Young Adults'
         WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
         WHEN Age BETWEEN 51 AND 60 THEN 'Older Adults'
         ELSE 'Senior Citizens'
     END AS Age_group,



     CASE
         WHEN Email IS NULL OR TRIM(Email)='' OR LOWER(Email)='none'
         THEN 0
         ELSE 1
     END AS Email_flag,

`Social Media Handle` AS Social_Media_Handle,

     CASE
         WHEN `Social Media Handle` IS NULL OR TRIM(`Social Media Handle`)='' OR LOWER(`Social Media Handle`)='none'
         THEN 0
         ELSE 1
     END AS SM_flag

FROM bright_tv_user_profile;

SELECT *
FROM USER_PROFILE;



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





CREATE OR REPLACE TEMPORARY TABLE VIEWERSHIP AS
SELECT
 User_ID,

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

FROM viewership_clean;


SELECT *
FROM VIEWERSHIP;






SELECT
      COALESCE (UserID, User_ID) AS Sub_ID,
      Watch_Date,
      Day_Name,
      Month_Name,
      Watch_Time,
      day_classification,
      tv_channel,
      duration,
      screen_time_bucket,
      hour_of_day,
      region,
      Sex,
      Ethnicity,
      Age_group,
      Email_flag,
      Social_Media_Handle,
      SM_Flag
      FROM VIEWERSHIP AS a LEFT JOIN USER_PROFILE AS ON UserID= User_ID;





 