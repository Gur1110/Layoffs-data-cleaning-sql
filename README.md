# Layoffs-data-cleaning-sql
"Data cleaning pipeline (SQL) for a layoffs dataset - deduplication, null handling, standardization"
## 🧹 Data Cleaning Steps (`layoffs_data_cleaning.sql`)

1. **Staged the raw data** — Created `layoffs_staging` as a copy of the raw `layoffs` table, so all cleaning happens without touching the original data.

2. **Removed duplicate rows** — Used a `ROW_NUMBER()` window function partitioned by all columns to flag exact duplicates, then created `layoffs_staging2` (with an added `row_num` column) and deleted rows where `row_num > 1`.

3. **Standardized text fields**
   - Trimmed extra whitespace from `company` names
   - Standardized inconsistent `industry` values (e.g. merged all `Crypto%` variants into a single `Crypto` label)
   - Cleaned trailing periods from `country` values (e.g. `"United States."` → `"United States"`)

4. **Fixed the `date` column** — Converted the `date` field from text to a proper `DATE` type using `STR_TO_DATE()`, then altered the column definition to enforce the `DATE` type going forward.

5. **Handled missing industry values** — Used a self-join on `company` to backfill missing/blank `industry` values from other rows of the same company that already had the industry filled in.

6. **Removed unusable rows** — Deleted rows where both `total_laid_off` and `percentage_laid_off` were `NULL`, since these rows carried no usable layoff data.

7. **Final cleanup** — Dropped the temporary `row_num` column used for deduplication, leaving a clean, analysis-ready table (`layoffs_staging2`).
8. **Verified data integrity**- Compared row counts between the raw layoffs table and the cleaned layoffs_staging2 table to confirm the extent of cleaning: reduced from 2,361 rows(raw) to 1,995 rows(cleaned) after removing duplicates and unusable rows.
That's 366 rows removed(~15.5%) through deduplication, invalid row removal, and cleanup steps.


## 📊 Exploratory Data Analysis (`layoffs_eda.sql`)

Key queries run and what they explored:

| Query | Purpose |
|-------|---------|
| `MAX(total_laid_off)`, `MAX(percentage_laid_off)` | Found the single largest layoff event and the highest layoff percentage in the dataset |
| Companies with `percentage_laid_off = 1` | Identified companies that laid off 100% of their staff (i.e. shut down entirely), sorted by size and by funds raised |
| `SUM(total_laid_off)` grouped by `company` | Ranked companies by total layoffs overall |
| `SUM(total_laid_off)` grouped by `industry`, `country`, and `date` | Broke down total layoffs by industry, country, and specific dates |
| `MIN(date)`, `MAX(date)` | Found the date range covered by the dataset |
| `SUM(total_laid_off)` grouped by `YEAR(date)` | Found total layoffs per year |
| `SUM(total_laid_off)` grouped by `stage` (company stage, e.g. Post-IPO, Series C) | Compared layoffs across company funding stages |
| Rolling total using `SUM() OVER()` with a CTE | Calculated a month-by-month rolling total of layoffs to visualize the trend over time |
| `DENSE_RANK()` with a CTE, partitioned by year | Ranked companies by total layoffs *within each year*, to find the top 5 companies with the most layoffs per year |

### 🏆 Top 5 Companies by Layoffs, Per Year (sample output)

| Year | Top Companies (Layoffs) |
|------|--------------------------|
| 2020 | Uber (7,525), Booking.com (4,375), Groupon (2,800), Swiggy (2,250), Airbnb (1,900) |
| 2021 | Bytedance (3,600), Katerra (2,434), Zillow (2,000), Instacart (1,877), WhiteHat Jr (1,800) |
| 2022 | Meta (11,000), Amazon (10,150), Cisco (4,100), Peloton (4,084), Carvana/Philips (4,000) |
| 2023 | Google (12,000), Microsoft (10,000), Ericsson (8,500), Amazon (8,000), Salesforce/Dell (8,000/6,650) |

*Layoffs escalated significantly year over year, with 2023 seeing the largest single-company layoffs (Google, Microsoft) in the dataset.*
