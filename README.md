# Spatial thinking & crime mapping in R: a half-day workshop

An interactive online workbook for a half-day taster workshop:
**"An introduction to spatial thinking and analysis using R as a crime mapping tool"**.

It is aimed at PhD students and staff from any discipline with little or no R or GIS experience. The
code runs **in the browser** (via [webR](https://docs.r-wasm.org/webr/latest/) and
[quarto-live](https://r-wasm.github.io/quarto-live/)), so participants don't need to install anything.
It is a condensed version of the University of Manchester's
[Crime Mapping module](https://maczokni.github.io/crime_mapping_textbook/). The module's own repository
is separate and was not modified.

## What's in here

| File | What it is |
|---|---|
| `index.qmd` | Welcome page: learning outcomes, schedule, choose-your-route guidance |
| `prepare.qmd` | Preparatory material: browser check, 15-minute primer, readings |
| `00-r-warmup.qmd` | Practical 0: R basics in 10 minutes (optional) |
| `01-spatial-data.qmd` | Practical 1: spreadsheet → map; points/lines/polygons; CRS |
| `02-units-of-analysis.qmd` | Practical 2: aggregation, counts vs rates, classification, MAUP |
| `03-spatial-operations.qmd` | Practical 3: select by location, buffers, points in polygon |
| `04-spatial-dependence.qmd` | Practical 4: neighbours, spatial lag, Moran's I, LISA |
| `next-steps.qmd` | Resources by background (new to both / know R / know GIS / practitioners) |
| `facilitator.qmd` | Instructor guide: running order, talk outlines, adapting to the room, troubleshooting |
| `slides/mini-lectures.qmd` | Reveal.js slides for the four ~10-minute talks (figures built from the workshop data) |
| `data/` | Small CSV datasets (~600 KB), read from GitHub by URL |
| `data-raw/` | Scripts that created `data/` from the module's data folder |
| `_extensions/r-wasm/live` | The quarto-live extension (MIT licence), vendored |

## Hosting on GitHub

1. Create a **public** repo called `crime_mapping_workshop` on your GitHub (`maczokni`). Push this folder to it.
2. Settings → Pages → **Source: GitHub Actions**. The included workflow builds and publishes on every push.
3. The site will be at `https://maczokni.github.io/crime_mapping_workshop/`.

**Data** is read straight from the repo:

```r
data_url <- "https://raw.githubusercontent.com/maczokni/crime_mapping_workshop/main/data/"
crimes <- read.csv(paste0(data_url, "crimes.csv"))
```

Different repo name or account? Find and replace that URL in the `.qmd` files.
The pages only work once the data is on GitHub.

## Building locally

- Open `crime_mapping_workshop.Rproj`, then **Build All** (runs `build.sh` = `quarto preview`).
- Needs Quarto, plus R packages `knitr`, `rmarkdown`, `sf`, `dplyr`, `ggplot2`, `classInt`, `spdep`, `patchwork` (for the slides).

## Editing

- Interactive blocks: ```` ```{webr} ````. Exercises: `#| exercise:`, `setup`, `.hint`, `.solution`. See the [quarto-live docs](https://r-wasm.github.io/quarto-live/).
- Each page is its own R session. Packages are listed under `webr: packages:` in each page's YAML.
- Exercise `setup` blocks reload their own data, so exercises work even if earlier blocks were skipped.

## Data and licences

- See `data-raw/README.md`. All open data, Open Government Licence v3.0 (police.uk, ONS, nomis, Manchester City Council). Contains OS data © Crown copyright. Geocoding © OpenStreetMap contributors.
- Text CC BY-SA 4.0. Code MIT. quarto-live extension MIT.
