Select *
From layoffs;

Select *
From layoffs
Order by company;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or blank values
-- 4. Ramove any Columns

#Creating another table to copy all the data from the raw table(world_layoffs) into the staging table.)

CREATE TABLE layoffs_staging
LIKE layoffs;

Select *
From layoffs_staging;

#Inserting the data into layoff_staging from layofss
INSERT INTO layoffs_staging
Select *
From layoffs;

Select *
From layoffs_staging;
#We created the another table and store the data into it, in case we made mistakes in staging database, we will need our raw data. Usually we do not work on the raw data.

-- To Remove the Duplicates
#(Putting row_numbers whi9ch will help to identify the duplicates)

Select *,
ROW_NUMBER() OVER(PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
From layoffs_staging;

#CREATING CTE

WITH duplicate_CTE AS
(
Select *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
From layoffs_staging
)
Select *
From duplicate_CTE
Where row_num > 1;
#(There will be the duplicates)

#Creating table and deleting the actual column( deleting extra rows which is = to 2) (From schemas>>layoffs_staging>>copy to clipboard>>create statementlayoffs_staging)
#If it's not working 
 
CREATE TABLE layoffs_staging2 LIKE layoffs_staging;

Select *
From layoffs_staging2;

DROP TABLE layoffs_staging2;


#Writing it manually to add row_num column into the duplicate table)
CREATE TABLE `layoffs_staging2` (
`company` text,
`location` text,
`industry` text, 
`total_laid_off` int DEFAULT NULL,
`percentage_laid_off` text, 
`date` text,
`stage` text,
`country` text,
`funds_raised_millions` int DEFAULT NULL,
`row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Select * 
From layoffs_staging2
Where row_num=2;

INSERT INTO layoffs_staging2
Select *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
From layoffs_staging;


Select *
From layoffs_staging2
Where row_num>1;

DELETE 
From layoffs_staging2
Where row_num>1;

SET SQL_SAFE_UPDATES = 0;

Select *
From layoffs_staging2;

-- STANDARDIZING THE DATA

Select company, TRIM(company)
From layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

Select *
From layoffs_staging;

Select DISTINCT industry
From layoffs_staging2
Order by 1;

Select *
From layoffs_staging
Where industry LIKE 'Crypto%';

UPDATE layoffs_staging2
SET industry = 'Crypto'
Where industry LIKE 'Crypto%';

#UPDATING 'LOCATION' COLUMN

Select DISTINCT location
From layoffs_staging2
Order by 1;

#COUNTRY COLUMN
Select DISTINCT country
From layoffs_staging2
Order by 1;

Select DISTINCT country, TRIM(TRAILING'.'From country)
From layoffs_staging2
Order by 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING'.'From country)
Where country LIKE 'United States%';

Select *
From layoffs_staging2;

#Converting the date-text format to DATE

Select `date`,
STR_TO_DATE ('date','%m/%d/%Y')
From layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%m/%d/%Y');

Select `date`
From layoffs_staging2;

  #OR
  
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

Select *
From layoffs_staging;


#REMOVING NULLS AND BLANKS FROM INDUSTRY COLUMN

Select *
From layoffs_staging2
Where industry IS NULL
OR industry =' ';

Select *
From layoffs_staging2
Where company = 'Airbnb';

Select t1.industry,t2.industry
From layoffs_staging2 t1
JOIN layoffs_staging2 t2
   ON t1.company = t2.company
Where(t1.industry IS NULL OR t1.industry = ' ')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
   ON t1.company = t2.company
SET t1.industry = t2.industry
Where t1.industry IS NULL
AND t2.industry IS NOT NULL;

Select *
From layoffs_staging2;

Select *
From layoffs_staging2
Where total_laid_off IS NULL
AND percentage_laid_off IS NULL;

#DELETING THE ROWS
DELETE
From layoffs_staging2
Where total_laid_off IS NULL
AND percentage_laid_off IS NULL;

Select *
From layoffs_staging2;

ALTER TABLE layoffs_staging2
DROP column row_num;

















