# Run once in RStudio, from the project folder (the folder with _quarto.yml):
#
#   source("data-raw/get_data.R")
#
# It writes two kinds of file into data/, which the workshop pages read from GitHub:
#   1. data/leeds_streets.csv  : street lines from OpenStreetMap (via Geofabrik),
#                                because live OpenStreetMap queries are too unreliable for a class.
#   2. data/backup/*.csv       : copies of everything the pages download live
#                                (police.uk, ONS, nomis), in case an API is down on the day.
#
# Then commit and push the data/ folder.
#
# Packages: install.packages(c("sf", "dplyr", "jsonlite", "osmextract"))

library(sf)
library(dplyr)
library(jsonlite)
library(osmextract)

dir.create("data/backup", recursive = TRUE, showWarnings = FALSE)

study_wards <- c("Little London & Woodhouse", "Hunslet & Riverside", "Headingley & Hyde Park")
crime_months <- c("2026-07", "2026-08")

# Save an sf object as CSV with the shape written as text (WKT) in a "geometry" column.
# CSV + WKT can be read straight from GitHub with read.csv(), including in browser R.
write_wkt_csv <- function(x, file) {
  df <- st_drop_geometry(x)
  df$geometry <- st_as_text(st_geometry(x), digits = 10)
  write.csv(df, file, row.names = FALSE)
}

# ---- 1. Boundaries from the ONS Open Geography Portal -------------------------------
ons <- "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/"

ward_url <- paste0(ons, "WD_MAY_2026_UK_BGC/FeatureServer/0/query?",
                   "where=LAD26NM%3D%27Leeds%27&outFields=WD26CD,WD26NM&outSR=4326&f=geojson")
download.file(ward_url, tf <- tempfile(fileext = ".geojson"), quiet = TRUE)
leeds_wards <- st_read(tf, quiet = TRUE)

lsoa_url <- paste0(ons, "LSOA_2021_EW_BSC_V4_RUC/FeatureServer/0/query?",
                   "where=LSOA21NM%20LIKE%20%27Leeds%25%27&outFields=LSOA21CD,LSOA21NM&outSR=4326&f=geojson")
download.file(lsoa_url, tf <- tempfile(fileext = ".geojson"), quiet = TRUE)
leeds_lsoa <- st_read(tf, quiet = TRUE)

write_wkt_csv(leeds_wards, "data/backup/leeds_wards.csv")
write_wkt_csv(leeds_lsoa, "data/backup/leeds_lsoa.csv")

study_area <- leeds_wards |> filter(WD26NM %in% study_wards) |> st_union()
bb <- st_bbox(study_area)

# ---- 2. Police neighbourhood boundary (police.uk API) --------------------------------
b <- fromJSON("https://data.police.uk/api/west-yorkshire/LDT_CITY/boundary")
write.csv(b, "data/backup/police_neighbourhood_LDT_CITY.csv", row.names = FALSE)

# ---- 3. Crimes for the study area (police.uk API) -------------------------------------
poly <- paste(c(paste(bb["ymin"], bb["xmin"], sep = ","), paste(bb["ymin"], bb["xmax"], sep = ","),
                paste(bb["ymax"], bb["xmax"], sep = ","), paste(bb["ymax"], bb["xmin"], sep = ",")),
              collapse = ":")
for (m in crime_months) {
  x <- fromJSON(paste0("https://data.police.uk/api/crimes-street/all-crime?poly=", poly, "&date=", m))
  x <- flatten(x)
  x <- x[, !sapply(x, is.list)]   # drop list columns (e.g. empty outcome_status)
  write.csv(x, paste0("data/backup/crimes_", m, ".csv"), row.names = FALSE)
}
# Town Hall 1-mile query used in the first exercise
x <- flatten(fromJSON("https://data.police.uk/api/crimes-street/all-crime?lat=53.7999&lng=-1.5492&date=2026-08"))
write.csv(x[, !sapply(x, is.list)], "data/backup/crimes_townhall_2026-08.csv", row.names = FALSE)

# ---- 4. Population (Census 2021, TS001, via nomis API) --------------------------------
pop <- read.csv(paste0("https://www.nomisweb.co.uk/api/v01/dataset/NM_2021_1.data.csv?date=latest",
                       "&geography=E08000035TYPE151&c2021_restype_3=0&measures=20100",
                       "&select=geography_code,geography_name,obs_value"))
write.csv(pop, "data/backup/leeds_lsoa_population.csv", row.names = FALSE)

# ---- 4b. Workplace population (Census 2021, WP001, nomis bulk download) ---------------
# Not in the nomis API: it is only published as a zip file of CSVs, one per geography.
download.file("https://www.nomisweb.co.uk/output/census/2021/wp001.zip",
              tf <- tempfile(fileext = ".zip"), mode = "wb", quiet = TRUE)
wp <- read.csv(unz(tf, "WP001_lsoa.csv"), check.names = FALSE)
names(wp) <- c("LSOA21CD", "LSOA21NM", "workplace")
wp <- wp[wp$LSOA21CD %in% leeds_lsoa$LSOA21CD, ]
write.csv(wp, "data/backup/leeds_lsoa_workplace.csv", row.names = FALSE)

# ---- 5. Streets from OpenStreetMap (Geofabrik West Yorkshire extract) ------------------
streets <- oe_get("West Yorkshire", layer = "lines", download_directory = tempdir(),
                  boundary = study_area, boundary_type = "clipsrc", quiet = TRUE)
keep <- c("motorway", "trunk", "primary", "secondary", "tertiary", "unclassified", "residential",
          "living_street", "pedestrian", "motorway_link", "trunk_link", "primary_link",
          "secondary_link", "tertiary_link")
streets <- streets |>
  filter(highway %in% keep) |>
  select(osm_id, name, highway) |>
  st_cast("LINESTRING", warn = FALSE) |>
  st_transform(27700) |>
  st_simplify(dTolerance = 2) |>       # 2 m: plenty for city mapping, much smaller file
  st_set_precision(1)
write_wkt_csv(streets, "data/leeds_streets.csv")

message("Done. Files written:\n", paste(c("data/leeds_streets.csv", list.files("data/backup", full.names = TRUE)),
                                        collapse = "\n"))
