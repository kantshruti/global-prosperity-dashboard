# 🌍 Global Prosperity Dashboard

An interactive, animated business-intelligence dashboard analyzing 55 years of human development (1952–2007) across 142 countries — life expectancy, population, and GDP per capita. Built to be **clicked, not just screenshotted**: a live link a recruiter can open and play with directly, no Power BI license or desktop app required.

**[👉 Open the live dashboard](./dashboard.html)** (or deploy it — see below)

## Why this project

Most portfolio dashboards are static screenshots of a Power BI report. This one ships as a real, interactive web page: drag the year slider, hit play and watch the Gapminder-style bubble animation move from 1952 to 2007, filter by continent, search the country table, and sort any column — all live in the browser.

## Project Highlights

- Loaded and modeled a 1,704-row country-year panel dataset into a relational **SQLite** database
- Wrote SQL views for KPI aggregation, population-weighted averages, and year-over-year comparisons (the SQL equivalent of DAX measures)
- Built ETL/cleaning steps (deduplication, type casting, schema constraints) — the SQL equivalent of Power Query transforms
- Designed an interactive dashboard with KPI cards, slicers, and an animated scatter/bubble chart
- Built insightful visualizations analyzing global health and economic trends over time

## Dashboard Includes

- ✅ KPI Cards (Population, Life Expectancy, GDP per Capita, Countries Tracked) — update live as you move the year slider
- ✅ Animated bubble chart: GDP per capita vs. life expectancy, bubble size = population, play/pause year animation
- ✅ Life Expectancy Trend by Continent (multi-line chart, 1952–2007)
- ✅ Top 10 Countries by Life-Expectancy Gain
- ✅ Top 10 Fastest-Growing Economies (GDP per capita multiple)
- ✅ Population Share by Continent (donut chart, updates per year)
- ✅ Country Explorer: searchable, sortable data table
- ✅ Interactive continent filters/slicers that cross-filter every chart

## Tools & Skills

Power BI · Excel · SQL · SQLite · Python (ETL) · Data Modeling · Data Visualization · JavaScript (Chart.js) · Dashboard Design · Business Intelligence · Storytelling with Data

## Data

Source: [Gapminder Foundation](https://www.gapminder.org/data/) country-year panel (life expectancy, population, GDP per capita), 1952–2007, 142 countries, 5 continents.

## Project Structure

```
global-prosperity-dashboard/
├── dashboard.html            # the deliverable — single self-contained file, no server needed
├── dashboard_template.html   # source template (edit this, then re-inject data — see below)
├── data/
│   ├── gapminder.csv         # raw source data
│   ├── gapminder.db          # SQLite database (schema + views)
│   └── dashboard_data.json   # pre-aggregated output of the SQL views, embedded into dashboard.html
├── sql/
│   └── schema_and_analysis.sql   # CREATE TABLE, cleaning notes, analytical views (DAX-equivalent)
└── README.md
```

## How It Was Built (the "Power Query + DAX" equivalent in SQL)

1. **Extract**: raw country-year CSV loaded into a `country_year` SQLite table with a composite primary key (`country`, `year`).
2. **Transform / clean**: type casting, null checks, continent label standardization — see comments in `sql/schema_and_analysis.sql`.
3. **Model**: four SQL views act as the reusable "measures" layer:
   - `v_global_kpis_by_year` — population-weighted global KPIs per year
   - `v_continent_trends` — population-weighted life expectancy & GDP per capita by continent/year
   - `v_life_expectancy_gain` — country-level change, 1952 vs. 2007
   - `v_gdp_growth` — country-level GDP per capita growth multiple, 1952 vs. 2007
4. **Serve**: the view outputs are exported to `dashboard_data.json` and embedded directly into `dashboard.html`, so the finished dashboard needs no backend or database connection to run — just open the file, or host it as a static page.

## Make It Live (recommended for your resume)

A file on your laptop won't impress anyone — link to it. Easiest free option, GitHub Pages:

1. Create a public GitHub repo (e.g. `global-prosperity-dashboard`) and push this folder to it.
2. In the repo settings, enable **GitHub Pages** → deploy from the `main` branch, root folder.
3. Rename `dashboard.html` to `index.html` (or point Pages at `dashboard.html` directly).
4. Your live link will be `https://<your-username>.github.io/global-prosperity-dashboard/`.
5. Put that link at the top of your resume/LinkedIn, next to the project title.

## Editing / Regenerating

If you change the SQL views or want to swap in new data:

```bash
# 1. Edit sql/schema_and_analysis.sql and re-run the ETL + view queries against data/gapminder.csv
# 2. Re-export the view outputs to data/dashboard_data.json
# 3. Inject the fresh JSON (and Chart.js, first time only) into dashboard_template.html:

python3 -c "
import json
data = open('data/dashboard_data.json').read()
json.loads(data)
tpl = open('dashboard_template.html').read()
out = tpl.replace('__DASHBOARD_DATA__', data)
open('dashboard.html','w').write(out)
"
```

Note: `dashboard.html` bundles Chart.js **inline** (no CDN `<script src>`), so the file works fully offline and can't be broken by an ad-blocker, firewall, or flaky network on the viewer's end — important since this is meant to be opened cold by a recruiter. If you regenerate from the template and it still has a `__CHARTJS_SOURCE__` placeholder, download the Chart.js v4 UMD build once and inject it the same way.

## Also Building It in Power BI Desktop

Since the SQL views already define the exact aggregations, they translate directly into Power BI:

- Import `data/gapminder.csv` via **Power Query** (Get Data → Text/CSV)
- Recreate the cleaning steps from `sql/schema_and_analysis.sql` (type casting, dedup, continent standardization)
- Recreate each SQL view as a **DAX measure**, e.g.:
  ```
  Weighted Life Expectancy =
  SUMX(country_year, country_year[life_expectancy] * country_year[population])
  / SUM(country_year[population])
  ```
- Build KPI cards, a scatter chart (GDP vs. life expectancy, size = population), a line chart by continent, and slicers for `year` and `continent`
- This gives you a `.pbix` companion piece if a job application specifically asks for Power BI file output.
