# Spatial thinking & crime mapping in R: a one-day workshop

An interactive online workbook for a one-day workshop:
**"An introduction to spatial thinking and analysis using R as a crime mapping tool"**.

It is aimed at PhD students and staff from any discipline with little or no R experience. The
code runs **in the browser** (via [webR](https://docs.r-wasm.org/webr/latest/) and
[quarto-live](https://r-wasm.github.io/quarto-live/)), so participants don't need to install anything.
It is adapted from the University of Manchester's
[Crime Mapping module](https://maczokni.github.io/crime_mapping_textbook/), using open data for Leeds. The module's own repository
is separate and was not modified.

## What's in here

| File | What it is |
|---|---|
| `index.qmd` | Welcome page: schedule, how it works, data |
| `prepare.qmd` | Preparatory material: readings, browser check |
| `00-r-warmup.qmd` | Practical 0: R basics in 10 minutes (optional) |
| `01-spatial-data.qmd` | Part 1: what is place; points (police.uk API), polygons (ONS boundaries), lines (streets); neighbourhoods, street segments |
| `02-making-maps.qmd` | Part 2: cartography; layers, map elements, counts vs rates (nomis API), classification, colour, binning |
| `03-spatial-autocorrelation.qmd` | Part 3: neighbours (rook and queen contiguity), spatial weights matrices (binary and row-standardised), spatial lag, Moran's I; autocorrelation in regression |
| `next-steps.qmd` | Resources by background (new to R / know R / practitioners) |
| `slides/mini-lectures.qmd` | Reveal.js slides for the four talks (figures built from `data/backup/`) |
| `data-raw/get_data.R` | Script that writes `data/` (run it yourself in RStudio) |
| `data/leeds_streets.csv` | OpenStreetMap streets for the study area, read from GitHub by URL |
| `data/backup/` | Copies of the live API data, in case an API is down on the day, and for the slides |
| `_extensions/r-wasm/live` | The quarto-live extension (MIT licence), vendored |

## Data

Most data are downloaded **live** in the browser, as participants would in their own research:

- Crime: [police.uk API](https://data.police.uk/docs/)
- Ward and LSOA boundaries: [ONS Open Geography Portal](https://geoportal.statistics.gov.uk/) (ArcGIS REST API)
- Population: [nomis API](https://www.nomisweb.co.uk/api/v01/help)

Streets come from OpenStreetMap (Geofabrik extract via `osmextract`), saved once as `data/leeds_streets.csv`.

To create or refresh `data/`:

```r
install.packages(c("sf", "dplyr", "jsonlite", "osmextract"))
source("data-raw/get_data.R")
```

Then commit and push `data/`. The pages read from:

```r
data_url <- "https://raw.githubusercontent.com/maczokni/crime_mapping_workshop/main/data/"
```

To use newer crime data, change `2026-07`/`2026-08` in the pages, the slides and `get_data.R`.

## Hosting on GitHub

The site is at [https://maczokni.github.io/crime_mapping_workshop/](https://maczokni.github.io/crime_mapping_workshop/), built by `.github/workflows/publish.yml` on every push to `main`.

## Building locally

- Open `crime_mapping_workshop.Rproj`, then **Build All** (runs `build.sh` = `quarto preview`).
- Needs Quarto, plus R packages `knitr`, `rmarkdown`, `sf`, `dplyr`, `ggplot2`, `classInt`, `spdep`, `patchwork` (for the slides).

## Editing

- Interactive blocks: ```` ```{webr} ````. Exercises: `#| exercise:`, `setup`, `.hint`, `.solution`. See the [quarto-live docs](https://r-wasm.github.io/quarto-live/).
- Each page is its own R session. Packages are listed under `webr: packages:` in each page's YAML.
- Each part starts with a "Run me first" block, so parts can be done independently.
- In the browser, `st_read(url)` doesn't work: use `download.file(url, f)` then `st_read(f)`. Map tiles and `tmap` don't work either, so maps use `ggplot2` + `ggspatial`.

## Data and licences

- police.uk, ONS and nomis data: Open Government Licence v3.0. Contains OS data © Crown copyright and database right. Streets © OpenStreetMap contributors (ODbL).
- Text CC BY-SA 4.0. Code MIT. quarto-live extension MIT.
