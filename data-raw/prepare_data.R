# Builds the small workshop datasets in data/ from the Crime Mapping module's data folder.
# Study area: 8 wards from Manchester city centre down to Fallowfield.
#
# Run from the project root:
#   Rscript data-raw/prepare_data.R ../crime_mapping_textbook/data
#
# Everything is written as CSV so it can be read straight from GitHub with read.csv()
# (this also works in the browser version of R, where st_read() on a URL does not).
# Areas keep their shape in a text column called `geometry` (WKT, British National Grid).
# Boundaries are simplified with mapshaper (npm install -g mapshaper) if it is installed.

suppressMessages({library(sf); library(dplyr)})
args <- commandArgs(trailingOnly = TRUE)
src <- if (length(args)) args[1] else "../crime_mapping_textbook/data"

study_wards <- c("Deansgate", "Piccadilly", "Ancoats & Beswick", "Ardwick",
                 "Hulme", "Moss Side", "Rusholme", "Fallowfield")

simplify <- function(x, keep = "30%") {
  if (Sys.which("mapshaper") == "") return(x)
  tmp_in <- tempfile(fileext = ".geojson"); tmp_out <- tempfile(fileext = ".geojson")
  st_write(x, tmp_in, quiet = TRUE)
  system2("mapshaper", c(tmp_in, "-simplify", keep, "keep-shapes", "-o", "precision=1", tmp_out))
  out <- suppressWarnings(st_read(tmp_out, quiet = TRUE))
  st_make_valid(st_set_crs(st_set_crs(out, NA), 27700))
}

write_wkt <- function(x, file) {
  x <- st_set_precision(x, 1)
  df <- st_drop_geometry(x)
  df$geometry <- st_as_text(st_geometry(x), digits = 10)
  write.csv(df, file, row.names = FALSE)
}

# Wards
wards <- st_read(file.path(src, "manchester_wards.geojson"), quiet = TRUE) |>
  filter(wd22nm %in% study_wards) |>
  transmute(ward_name = wd22nm)
area <- st_union(wards)

# LSOAs whose centre falls in the study area
lsoa_all <- st_read(file.path(src, "BoundaryData/england_lsoa_2021.shp"), quiet = TRUE)
inside <- lengths(st_intersects(st_point_on_surface(st_geometry(lsoa_all)), area)) > 0
lsoa <- lsoa_all[inside, ] |> select(lsoa21cd, lsoa21nm)

wards <- simplify(wards)
lsoa  <- simplify(lsoa)
write_wkt(wards, "data/wards.csv")
write_wkt(lsoa, "data/lsoa.csv")

# Crimes, June 2019 (police.uk), in those LSOAs
read.csv(file.path(src, "crimes_w_lsoa_codes_attached.csv")) |>
  filter(lsoa21cd %in% lsoa$lsoa21cd) |>
  transmute(crime_type = Crime.type, longitude = Longitude, latitude = Latitude,
            location = Location, outcome = Last.outcome.category, lsoa21cd) |>
  write.csv("data/crimes.csv", row.names = FALSE)

# Census 2021 population
read.csv(file.path(src, "census_lsoa_manchester.csv")) |>
  filter(geography_code %in% lsoa$lsoa21cd) |>
  transmute(lsoa21cd = geography_code, respop, wkdpop = round(wkdpop)) |>
  write.csv("data/population.csv", row.names = FALSE)

# Licensed premises (M1 postcodes, geocoded with OpenStreetMap)
read.csv(file.path(src, "city_centre_prems.csv")) |>
  filter(!is.na(latitude), !is.na(longitude)) |>
  transmute(premises = PREMISESNAME, postcode = POSTCODE,
            longitude = round(longitude, 6), latitude = round(latitude, 6)) |>
  write.csv("data/licensed_premises.csv", row.names = FALSE)

cat("Done. LSOAs:", nrow(lsoa), "\n")
