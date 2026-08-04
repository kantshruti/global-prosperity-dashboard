/* ============================================================
   GLOBAL PROSPERITY DASHBOARD — SQL LAYER
   Source: Gapminder (country-year panel, 1952-2007, 142 countries)
   Loaded from data/gapminder.csv into SQLite (data/gapminder.db)
   ============================================================ */

-- 1. SCHEMA -----------------------------------------------------
DROP TABLE IF EXISTS country_year;
CREATE TABLE country_year (
    country          TEXT NOT NULL,
    continent        TEXT NOT NULL,
    year             INTEGER NOT NULL,
    life_expectancy  REAL NOT NULL,
    population       INTEGER NOT NULL,
    gdp_per_capita   REAL NOT NULL,
    iso_alpha        TEXT,
    iso_num          INTEGER,
    PRIMARY KEY (country, year)
);

CREATE INDEX idx_year      ON country_year(year);
CREATE INDEX idx_continent ON country_year(continent);

-- 2. CLEANING NOTES (equivalent to Power Query steps) ------------
-- - Removed duplicate country/year rows (composite PK enforces uniqueness)
-- - Verified no nulls in life_expectancy / population / gdp_per_capita
-- - Standardized continent labels (5 categories: Asia, Europe, Africa, Americas, Oceania)
-- - year cast to INTEGER, population/gdp_per_capita cast to numeric types

-- 3. CORE ANALYTICAL VIEWS (equivalent to DAX measures) -----------

-- Global KPIs per year: population-weighted life expectancy & GDP per capita
DROP VIEW IF EXISTS v_global_kpis_by_year;
CREATE VIEW v_global_kpis_by_year AS
SELECT
    year,
    COUNT(DISTINCT country)                                                AS countries_tracked,
    SUM(population)                                                        AS total_population,
    ROUND(SUM(life_expectancy * population) * 1.0 / SUM(population), 2)    AS weighted_life_expectancy,
    ROUND(SUM(gdp_per_capita * population) * 1.0 / SUM(population), 2)     AS weighted_gdp_per_capita
FROM country_year
GROUP BY year
ORDER BY year;

-- Continent-level trend: weighted life expectancy & GDP per capita by year
DROP VIEW IF EXISTS v_continent_trends;
CREATE VIEW v_continent_trends AS
SELECT
    continent,
    year,
    COUNT(DISTINCT country)                                                AS countries,
    SUM(population)                                                        AS population,
    ROUND(SUM(life_expectancy * population) * 1.0 / SUM(population), 2)    AS weighted_life_expectancy,
    ROUND(SUM(gdp_per_capita * population) * 1.0 / SUM(population), 2)     AS weighted_gdp_per_capita
FROM country_year
GROUP BY continent, year
ORDER BY continent, year;

-- Country-level change 1952 -> 2007 (biggest gains in life expectancy)
DROP VIEW IF EXISTS v_life_expectancy_gain;
CREATE VIEW v_life_expectancy_gain AS
SELECT
    a.country,
    a.continent,
    a.life_expectancy AS life_expectancy_1952,
    b.life_expectancy AS life_expectancy_2007,
    ROUND(b.life_expectancy - a.life_expectancy, 1) AS gain_years
FROM country_year a
JOIN country_year b ON a.country = b.country AND a.year = 1952 AND b.year = 2007
ORDER BY gain_years DESC;

-- Country-level GDP per capita growth (multiple), 1952 -> 2007
DROP VIEW IF EXISTS v_gdp_growth;
CREATE VIEW v_gdp_growth AS
SELECT
    a.country,
    a.continent,
    a.gdp_per_capita AS gdp_1952,
    b.gdp_per_capita AS gdp_2007,
    ROUND(b.gdp_per_capita * 1.0 / a.gdp_per_capita, 2) AS growth_multiple
FROM country_year a
JOIN country_year b ON a.country = b.country AND a.year = 1952 AND b.year = 2007
ORDER BY growth_multiple DESC;

-- 4. EXAMPLE QUERIES USED TO POWER THE DASHBOARD -------------------

-- Top 10 countries by life-expectancy gain (1952-2007)
-- SELECT * FROM v_life_expectancy_gain LIMIT 10;

-- Top 10 fastest-growing economies by GDP per capita multiple
-- SELECT * FROM v_gdp_growth LIMIT 10;

-- Global KPI card values for a given year (e.g. latest year, 2007)
-- SELECT * FROM v_global_kpis_by_year WHERE year = 2007;

-- Continent population share for a given year
-- SELECT continent, SUM(population) AS pop,
--        ROUND(100.0 * SUM(population) / (SELECT SUM(population) FROM country_year WHERE year = 2007), 1) AS pct
-- FROM country_year WHERE year = 2007 GROUP BY continent ORDER BY pop DESC;
