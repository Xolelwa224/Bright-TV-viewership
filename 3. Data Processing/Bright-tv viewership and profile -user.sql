-- Databricks notebook source
USE brightlearn2.data2;


-- COMMAND ----------

--- USER PROFILE
--- View the Dataset
SELECT *
FROM bright_tv_user_profile;

--- Check the Table Structure
--- Count Total Records
SELECT COUNT(*) AS Total_Users
FROM bright_tv_user_profile;


--- Check for Duplicate User IDs
SELECT
    UserID,
    COUNT(*) AS duplicate_count
FROM bright_tv_user_profile
GROUP BY UserID
HAVING COUNT(*) > 1;

--- If the number of rows changes after using DISTINCT, then duplicate rows exist.
SELECT DISTINCT *
FROM bright_tv_user_profile;


--- Check Missing User IDs
SELECT *
FROM bright_tv_user_profile
WHERE UserID IS NULL;




--- DATA CLEANING  FOR DATA COLUMNS
--- CLEAN GENDER
SELECT DISTINCT Gender
FROM bright_tv_user_profile;

--- Replace blanks and NULL values with Unknown.
SELECT DISTINCT
    CASE
         WHEN Gender IS NULL THEN 'Unknown'
         WHEN TRIM(Gender) = '' THEN 'Unknown'
         WHEN LOWER(Gender) = 'none' THEN 'Unknown'
         ELSE INITCAP(TRIM(Gender))
    END AS Sex
FROM bright_tv_user_profile;


--- CLEAN PROVINCE
SELECT DISTINCT Province
FROM bright_tv_user_profile;

--- Replace blanks and NULL values with Uncategorized.
SELECT DISTINCT
    CASE
         WHEN Province IS NULL THEN 'Uncategorized'
         WHEN TRIM(Province) = '' THEN 'Uncategorized'
         WHEN LOWER(Province)='none' THEN 'Uncategorized'
         ELSE INITCAP(TRIM(Province))
    END AS region
FROM bright_tv_user_profile;



--- CLEANING RACE
SELECT DISTINCT Race
FROM bright_tv_user_profile;

--- Replace blanks and NULL and other values with unkonwn.
SELECT DISTINCT
    CASE
        WHEN Race IS NULL THEN 'Unknown'
         WHEN TRIM(Race)='' THEN 'Unknown'
         WHEN LOWER(Race)='other' THEN 'Unknown'
         WHEN LOWER(Race)='none' THEN 'Unknown'
        ELSE INITCAP(TRIM(Race))
    END AS race
FROM bright_tv_user_profile;



--- CLEANING EMAIL FLAG
SELECT DISTINCT Email
FROM bright_tv_user_profile;

--- Determine whether a user has a valid email.
SELECT
    Email,
    CASE
        WHEN Email IS NULL THEN 0
        WHEN TRIM(Email) = '' THEN 0
        WHEN LOWER(Email) = 'none' THEN 0
        ELSE 1
    END AS Email_flag
FROM bright_tv_user_profile;


--- CLEANING SOCIAL MEDIA FLAG
SELECT DISTINCT `Social Media Handle`
FROM bright_tv_user_profile;  

SELECT DISTINCT
     CASE
         WHEN `Social Media Handle` IS NULL THEN 0
         WHEN TRIM(`Social Media Handle`) = '' THEN 0
         WHEN LOWER(`Social Media Handle`) = 'none' THEN 0
         ELSE 1
     END AS SM_flag
FROM bright_tv_user_profile; 


-- CLEANING AGE GROUPS 
SELECT DISTINCT Age
FROM bright_tv_user_profile;

SELECT DISTINCT
CASE
WHEN Age < 13 THEN 'Kids'
WHEN Age BETWEEN 13 AND 17 THEN 'Youth'
WHEN Age BETWEEN 18 AND 35 THEN 'Young Adults'
WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
WHEN Age BETWEEN 51 AND 60 THEN 'Older Adults'
ELSE 'Senior Citizens'
END AS age_group
FROM bright_tv_user_profile;



--- CREATING A CLEAN BIG TABLE

SELECT DISTINCT
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

Age,

     CASE
         WHEN Age < 13 THEN 'Kids'
         WHEN Age BETWEEN 13 AND 17 THEN 'Youth'
         WHEN Age BETWEEN 18 AND 35 THEN 'Young Adults'
         WHEN Age BETWEEN 36 AND 50 THEN 'Adults'
         WHEN Age BETWEEN 51 AND 60 THEN 'Older Adults'
         ELSE 'Senior Citizens'
     END AS Age_group,

email,

     CASE
         WHEN Email IS NULL OR TRIM(Email)='' OR LOWER(Email)='none'
         THEN 0
         ELSE 1
     END AS Email_flag,

`Social media handle`,

     CASE
         WHEN `Social Media Handle` IS NULL OR TRIM(`Social Media Handle`)='' OR LOWER( `Social Media handle`)='none'
         THEN 0
         ELSE 1
     END AS SM_flag

FROM bright_tv_user_profile;









