-- Data Cleaning --
-- Steps for Data Cleaning and standarization
/*  1. Remove Duplicates
	2. Standardize the data 
    3. Dealing with Null values
    4. Remove Columns that are not required
*/

SELECT * FROM layoffs;

-- Make a copy of the raw data so we do not lose any original data
-- copy of the raw data in 'layoffs_staging'

CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;

SELECT * FROM layoffs_staging;

-- STEP 1: Remove Duplicates: We see there are no Unique identification numbers, hence we assign
-- 			rownumbers over the table partionining by all the attributes. Keeping note that date is a 
-- 			keyword and hence it willbe written in ` `

SELECT *,
row_number() OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off,`date`, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

WITH duplicate_CTE AS
(SELECT *,
row_number() OVER(
PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off,`date`, country, funds_raised_millions) AS row_num
FROM layoffs_staging)
SELECT * FROM
duplicate_CTE
WHERE row_num = 1;

-- Add a new column row_num by altering the table in INT data type

ALTER TABLE world_layoffs.layoffs_staging ADD row_num INT;


-- Delete all rows which are duplicate, ie, with row_num > 1 by creating a CTE
WITH DELETE_CTE AS (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
)
DELETE FROM layoffs_staging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
	FROM DELETE_CTE
) 
AND row_num > 1;

-- STEP 2: Standardizing the table. Finding issues in spellings, spaces and fixing them

UPDATE layoffs_staging
SET company = TRIM(company);

UPDATE layoffs_staging
SET company = TRIM(location);

UPDATE layoffs_staging
SET country = TRIM(TRAILING '.' FROM country);

SELECT DISTINCT(country) FROM layoffs_staging
ORDER BY 1;

-- Change the date format as well as the data type from Text to DATE

UPDATE layoffs_staging
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y')
;

--  Changing datatype to DATE from TEXT
ALTER TABLE layoffs_staging
MODIFY COLUMN `date` DATE;

SELECT DISTINCT(industry) FROM layoffs_staging
ORDER BY 1;
-- we see that the industry Crypto, cryptocurrency all ahs to be normalised to crypto

UPDATE layoffs_staging
SET industry = 'Crypto'
WHERE industry LIKE 'crypto%';

-- STEP 3: NULL Values: Delete NULL values, Populate values where ever possible

SELECT *
FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL;


SELECT *
FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use
DELETE FROM world_layoffs.layoffs_staging
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- STEP4: DELETING unwated rows
-- we added a new row called row_num for our convenience. we would be deleteing that

ALTER TABLE layoffs_staging
DROP COLUMN row_num;

SELECT * FROM layoffs_staging;








