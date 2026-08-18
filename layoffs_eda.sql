-- EXPLORATORY DATA ANALYSIS

Select *
from layoffs_staging2;

Select MAX(total_laid_off), MAX(percentage_laid_off)
From layoffs_staging2;

Select *
From layoffs_staging2
Where percentage_laid_off = 1;


Select *
From layoffs_staging2
Where percentage_laid_off = 1
Order by total_laid_off;


Select *
From layoffs_staging2
Where percentage_laid_off = 1
Order by funds_raised_millions DESC;

Select company, SUM(total_laid_off)
From layoffs_staging2
Group by company
Order by 2 DESC;

Select MIN(`date`), MAX(`date`)
From layoffs_staging2;

Select industry, SUM(total_laid_off)
From layoffs_staging2
Group by industry
Order by 2 DESC;

Select country, SUM(total_laid_off)
From layoffs_staging2
Group by country
Order by 2 DESC;

Select `date`, SUM(total_laid_off)
From layoffs_staging2
Group by `date`
Order by 2 DESC;

Select Year(`date`),SUM(total_laid_off)
From layoffs_staging2
Group by Year(`date`)
Order by 1 DESC;

Select stage, SUM(total_laid_off)
From layoffs_staging2
Group by stage
Order by 2 DESC;

-- ROLLING_TOTAL OF LAYOFFS

Select SUBSTRING(`date`,1,7) AS Month, SUM(total_laid_off)
From layoffs_staging2
Where SUBSTRING(`date`,1,7) IS NOT NULL 
Group by Month
order by 1 ASC;

WITH Rolling_Total AS 
(
Select SUBSTRING(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_off
From layoffs_staging2
Where SUBSTRING(`date`,1,7) IS NOT NULL 
Group by `Month`
Order by 1 ASC
)

Select `MONTH`, total_off,
SUM(total_off) OVER(Order by `MONTH`) AS Rolling_total
From Rolling_Total;


Select company, SUM(total_laid_off)
From layoffs_staging2
Group by company
Order by 2 DESC;

Select company, YEAR(`date`), SUM(total_laid_off)
From layoffs_staging2
Group by company, YEAR(`date`)
Order by 3 DESC;

#RANKING THE MOST LAID_OFF YEAR

WITH Company_year(company, years, total_laid_off) AS
(
Select company, YEAR(`date`), SUM(total_laid_off)
From layoffs_staging2
Group by company, YEAR(`date`)
), 
Company_Year_Rank AS
(
Select *,
DENSE_RANK() OVER(PARTITION BY years Order by total_laid_off DESC) AS Ranking
From Company_year
Where years IS NOT NULL
)

Select *
From Company_year_Rank
Where Ranking <=5
;

