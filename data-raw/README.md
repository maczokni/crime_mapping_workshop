# Workshop data

Small extracts of the Crime Mapping module data. Study area: 8 wards from the city centre to Fallowfield
(Deansgate, Piccadilly, Ancoats & Beswick, Ardwick, Hulme, Moss Side, Rusholme, Fallowfield).

Rebuild: `Rscript data-raw/prepare_data.R ../crime_mapping_textbook/data`
(boundaries are simplified with mapshaper if installed: `npm install -g mapshaper`).

| File | Rows | Columns |
|---|---|---|
| `crimes.csv` | 3,445 | crime_type, longitude, latitude (WGS 84), location, outcome, lsoa21cd. June 2019 |
| `lsoa.csv` | 67 | lsoa21cd, lsoa21nm, geometry (WKT, EPSG:27700) |
| `population.csv` | 67 | lsoa21cd, respop, wkdpop. Census 2021 |
| `wards.csv` | 8 | ward_name, geometry (WKT, EPSG:27700) |
| `licensed_premises.csv` | 246 | premises, postcode, longitude, latitude. M1 postcodes, OSM-geocoded |

Everything is CSV so it reads straight from GitHub with `read.csv(url)`, in RStudio and in the browser.
(`st_read()` on a URL doesn't work in browser R.) Areas become spatial with
`st_as_sf(wkt = "geometry", crs = 27700)`.
