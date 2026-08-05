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






















Step 1 - Start with the basic SELECT

The first thing we do is decide which columns we want to keep.

SELECT

UserID,
RecordDate2,
Duration2,
Channel2,
Age,
Gender,
Race,
Region,
Email_Flag,
GM_Flag

FROM BrightTV_Clean;

What this teaches:

SELECT tells SQL which columns to return.
FROM tells SQL where the data comes from.
At this stage, you're not changing anything—just checking that the table looks correct.


Step 2 - Create a proper date

Instead of using the original date column directly, create a cleaned date.

SELECT

UserID,

TO_DATE(RecordDate2) AS Watch_Date,

Duration2,
Channel2,
Age,
Gender,
Race,
Region,
Email_Flag,
GM_Flag

FROM BrightTV_Clean;
New syntax
TO_DATE(RecordDate2)

Converts text or timestamp into a SQL Date.

AS Watch_Date

Renames the column.

Step 3 - Extract the year

Now add another column.

SELECT

UserID,

TO_DATE(RecordDate2) AS Watch_Date,

YEAR(TO_DATE(RecordDate2)) AS Watch_Year,

Duration2,
Channel2,
Age,
Gender,
Race,
Region,
Email_Flag,
GM_Flag

FROM BrightTV_Clean;

Notice we didn't remove anything.

We simply added

YEAR(...)
Step 4 - Extract the month number
SELECT

UserID,

TO_DATE(RecordDate2) AS Watch_Date,

YEAR(TO_DATE(RecordDate2)) AS Watch_Year,

MONTH(TO_DATE(RecordDate2)) AS Month_Number,

Duration2,
Channel2,
Age,
Gender,
Race,
Region,
Email_Flag,
GM_Flag

FROM BrightTV_Clean;

Now your dashboard can sort months correctly.

Step 5 - Add the month name
SELECT

UserID,

TO_DATE(RecordDate2) AS Watch_Date,

YEAR(TO_DATE(RecordDate2)) AS Watch_Year,

MONTH(TO_DATE(RecordDate2)) AS Month_Number,

MONTHNAME(TO_DATE(RecordDate2)) AS Month_Name,

Duration2,
Channel2,
Age,
Gender,
Race,
Region,
Email_Flag,
GM_Flag

FROM BrightTV_Clean;

Now you'll have

Month_Number	Month_Name
1	January
2	February
3	March
Step 6 - Day of the week
SELECT

UserID,

TO_DATE(RecordDate2) AS Watch_Date,

YEAR(TO_DATE(RecordDate2)) AS Watch_Year,

MONTH(TO_DATE(RecordDate2)) AS Month_Number,

MONTHNAME(TO_DATE(RecordDate2)) AS Month_Name,

DAYNAME(TO_DATE(RecordDate2)) AS Day_Name,

Duration2,
Channel2,
Age,
Gender,
Race,
Region,
Email_Flag,
GM_Flag

FROM BrightTV_Clean;

Result

Watch_Date	Day_Name
2025-05-10	Saturday
Step 7 - Weekend or Weekday

Now we introduce our first CASE WHEN.

SELECT

UserID,

TO_DATE(RecordDate2) AS Watch_Date,

DAYNAME(TO_DATE(RecordDate2)) AS Day_Name,

CASE

WHEN DAYNAME(TO_DATE(RecordDate2))
IN ('Saturday','Sunday')

THEN 'Weekend'

ELSE 'Weekday'

END AS Day_Type,

Duration2,
Channel2

FROM BrightTV_Clean;
New syntax
CASE

means

"If something is true, return this value."

Step 8 - Extract the time
SELECT

UserID,

TO_DATE(RecordDate2) AS Watch_Date,

DATE_FORMAT(RecordDate2,'HH:mm:ss') AS Watch_Time,

Duration2,
Channel2

FROM BrightTV_Clean;

Example

14:35:20
Step 9 - Time of day
SELECT

UserID,

DATE_FORMAT(RecordDate2,'HH:mm:ss') AS Watch_Time,

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

FROM BrightTV_Clean;
Step 10 - Age Group
SELECT

UserID,

Age,

CASE

WHEN Age<=1 THEN 'Infant'

WHEN Age BETWEEN 2 AND 12 THEN 'Child'

WHEN Age BETWEEN 13 AND 19 THEN 'Teen'

WHEN Age BETWEEN 20 AND 35 THEN 'Young Adult'

WHEN Age BETWEEN 36 AND 59 THEN 'Adult'

ELSE 'Senior'

END AS Age_Group

FROM BrightTV_Clean;
Step 11 - Clean Gender

Instead of leaving blanks:

SELECT

UserID,

CASE

WHEN Gender IS NULL THEN 'Unknown'

ELSE Gender

END AS Gender

FROM BrightTV_Clean;
Step 12 - Group TV Channels
SELECT

UserID,

CASE

WHEN Channel2 IN
(
'SuperSport Live Events 1',
'SuperSport Live Events 2',
'SuperSport Live Events 3'
)

THEN 'SuperSport Live'

WHEN Channel2 IN
(
'Soweto TV',
'Soweto TV HD'
)

THEN 'Soweto TV'

ELSE Channel2

END AS TV_Channel

FROM BrightTV_Clean;
Final Step - Create the new cleaned table

Once you've tested each transformation individually and you're happy with the results, combine them into one query:

CREATE OR REPLACE TABLE BrightTV_Final AS

SELECT

UserID,

TO_DATE(RecordDate2) AS Watch_Date,

YEAR(TO_DATE(RecordDate2)) AS Watch_Year,

MONTH(TO_DATE(RecordDate2)) AS Month_Number,

MONTHNAME(TO_DATE(RecordDate2)) AS Month_Name,

DAYNAME(TO_DATE(RecordDate2)) AS Day_Name,

CASE
    WHEN DAYNAME(TO_DATE(RecordDate2)) IN ('Saturday','Sunday')
    THEN 'Weekend'
    ELSE 'Weekday'
END AS Day_Type,

DATE_FORMAT(RecordDate2,'HH:mm:ss') AS Watch_Time,

CASE
    WHEN DATE_FORMAT(RecordDate2,'HH:mm:ss') BETWEEN '00:00:00' AND '05:59:59' THEN 'Midnight'
    WHEN DATE_FORMAT(RecordDate2,'HH:mm:ss') BETWEEN '06:00:00' AND '11:59:59' THEN 'Morning'
    WHEN DATE_FORMAT(RecordDate2,'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
    ELSE 'Evening'
END AS Time_of_Day,

Duration2,

Channel2,

CASE
    WHEN Age <= 1 THEN 'Infant'
    WHEN Age BETWEEN 2 AND 12 THEN 'Child'
    WHEN Age BETWEEN 13 AND 19 THEN 'Teen'
    WHEN Age BETWEEN 20 AND 35 THEN 'Young Adult'
    WHEN Age BETWEEN 36 AND 59 THEN 'Adult'
    ELSE 'Senior'
END AS Age_Group,

CASE
    WHEN Gender IS NULL THEN 'Unknown'
    ELSE Gender
END AS Gender,

Race,
Region,
Email_Flag,
GM_Flag

FROM BrightTV_Clean;
How we'll continue

I recommend we treat this as a real project. In the next lesson, we can build the BrightTV_Final table one section at a time:

Date columns (Calendar Dimension)
Time columns (Time Dimension)
User Profile cleaning (Age, Gender, Race, Region)
TV Channel standardization
Duration and viewing buckets
Create summary tables using COUNT(), SUM(), AVG(), MIN(), and MAX() for dashboards.

This approach mirrors how analysts work in industry and will help you understand not just the SQL syntax, but also the reasoning behind each transformation.
























