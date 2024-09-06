# SQL – Data Cleaning Project in MySQL

## Project Overview

**Project Title**: Data Cleaning   
**Level**: Intermediate  
**Database**: `world_layoffs`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore and  clean, any data. The project involves setting up a world layoffs database, consisting of different companies from different countries and industries with their total number of employees that has been  laid off, their percentage laid_off numbers and the dates when they have laid off. This project uses different Querying methods to meet the objectives.

## Objectives

1. **Set up a world_layoff database**: Create and populate the database with the provided layoffs data.
2. **Data Cleaning_1 – Remove Duplicates**: We remove any duplicate entries that have been included in the data
3. **Data Cleaning_2 – Standardize the data** : We remove extra spaces ,trailing text and normalize certain repetitive values
4. **Data Cleaning_3 – Null Values or blank values**: Null values or blank spaces should be removed so that exploratory data analysis will be more accurate
5. **Data Cleaning_4 – Remove any unwanted rows** : Certain rows like row_num, which is no more required will be removed. 

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `world_layoffs`.
- **Table Creation**: A table named `layoffs` is created to store the data. The table structure includes columns for company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions. We populate this table with data by importing .csv file.
We would keep this raw data and would work on the copy of this which is layoffs_staging.

```sql
CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT layoffs_staging 
SELECT * FROM world_layoffs.layoffs;


### 2. Data Cleaning_1 - Remove Duplicates

- We check for any duplicates and then remove.
- But since there is no unique identification for individual rows, we would create row numbers using CTE or common table expression partitioning by all the columns.

-	And the we would identify the duplicate entries with any rows with row_num > 1. We delete those rows and update the table.

```sql

ALTER TABLE world_layoffs.layoffs_staging ADD row_num INT;

WITH DELETE_CTE AS 
(
SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		world_layoffs.layoffs_staging
) duplicates
WHERE 
	row_num > 1
)
DELETE
FROM DELETE_CTE
;

### 3. Data Cleaning_2 – Standardize the data

By standardising we mean that we remove any extra spaces in the beginning and end of each entries, any trailing text, changing the date format and normalising repetitive entries of same type of data For eg: under industry we had crypto, cryptocurrency and cryptocurrency. Which was normalised to crypto for all three occurences.

```Sql


UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);


UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry IN ('Crypto Currency', 'CryptoCurrency');

UPDATE layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging
MODIFY COLUMN `date` DATE;



### 4. Data Cleaning_3 – Null values or empty values

 
```Sql

SELECT *
FROM world_layoffs.layoffs_staging
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

SELECT *
FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL;

-- Delete Useless data we can't really use

DELETE FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

###5. Data Cleaning_4 – removing unwanted Rows.

-	Certain rows like row_num, which is no more required will be removed.
``` sql
ALTER TABLE layoffs_staging
DROP COLUMN row_num;


## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup and
 data cleaning in MySQL. The data available after this process is ready for further exploratory data analysis.

