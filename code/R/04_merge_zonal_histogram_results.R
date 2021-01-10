# Script to merge the results of the 03_zonal_histogram script and export new polygon shapefiles
# This script should be used after the 03_zonal_histogram.
# When reading dbf files, if a name starts with the number it gets an "X" added at the beginning
# this is normal and not an error, the X will be removed when the dataframes are merged.

# Data Manipulation - Annual Data -------------------------------------------------------
source("./code/R/functions/get_zonal_histo_pct.R")

library(rgdal)
library(tidyverse)
library(janitor)
library(foreign)
library(magrittr)
library(here)

# Load the polygon data
sites_mos_polys <- readOGR(here::here("data/shp", "sites_mosul_polys.shp"), stringsAsFactors = FALSE)
sites_ham_polys <- readOGR(here::here("data/shp", "sites_hamrin_polys.shp"), stringsAsFactors = FALSE)
# sites_had_polys <- readOGR(here::here("data/shp", "sites_haditha_polys.shp"), stringsAsFactors = FALSE)

# load the results of the 03_zonal_histogram script
mos_names <- list.files(here::here("output/shp/annual"),
  pattern = "mos.*.dbf",
  ignore.case = FALSE
)

ham_names <- list.files(here::here("output/shp/annual"),
  pattern = "ham.*.dbf",
  ignore.case = FALSE
)

had_names <- list.files(here::here("output/shp/annual"),
  pattern = "had.*.dbf",
  ignore.case = FALSE
)


# read.dbf is from the "foreign" package
# Using the dbf file we can import data directly as data frame for easier processing

mos_dbf_year_list <- lapply(mos_names, function(fn) {
  read.dbf(here::here("output/shp/annual", fn), as.is = TRUE)
})

ham_dbf_year_list <- lapply(ham_names, function(fn) {
  read.dbf(here::here("output/shp/annual", fn), as.is = TRUE)
})

had_dbf_year_list <- lapply(had_names, function(fn) {
  read.dbf(here::here("output/shp/annual", fn), as.is = TRUE)
})



# Data manipulation

# Apply the function to get a data frame with columns containing zonal percentages of all the loaded dbf
# This represent the percentage of site area emerged and submerged each year
# Apply the function on the datasets and replace the original data of the SpatialPolygonDataFrame
# to have GIS-ready shapefiles to export.
sites_mos_polys@data <- get_zonal_pct(mos_dbf_year_list)
sites_ham_polys@data <- get_zonal_pct(ham_dbf_year_list)
sites_had_polys@data <- get_zonal_pct(had_dbf_year_list)

# Export the results
writeOGR(
  obj = sites_mos_polys,
  dsn = here::here("output/shp/perc_poly_mos.shp"),
  layer = "perc_poly_mos",
  driver = "ESRI Shapefile", overwrite_layer = TRUE
)
writeOGR(
  obj = sites_ham_polys,
  dsn = here::here("output/shp/perc_poly_ham.shp"),
  layer = "perc_poly_ham",
  driver = "ESRI Shapefile", overwrite_layer = TRUE
)

writeOGR(
  obj = sites_had_polys,
  dsn = here::here("output/shp/perc_poly_had.shp"),
  layer = "perc_poly_had",
  driver = "ESRI Shapefile", overwrite_layer = TRUE
)




# Data Manipulation - Monthly Data -------------------------------------------------------

mos_names <- paste0("mos_", tolower(month.abb), ".dbf")
ham_names <- paste0("ham_", tolower(month.abb), ".dbf")
# had_names <- paste0("had_", tolower(month.abb), ".dbf")


mos_dbf_monthly_list <- lapply(mos_names, function(fn) {
  read.dbf(here::here("output/shp/monthly", fn), as.is = TRUE)
})
ham_dbf_monthly_list <- lapply(ham_names, function(fn) {
  read.dbf(here::here("output/shp/monthly", fn), as.is = TRUE)
})

had_dbf_monthly_list <- lapply(had_names, function(fn) {
  read.dbf(here::here("output/shp/monthly", fn), as.is = TRUE)
})



# Start the data manipulation
# Create different SpatialPolygonsDataFrame to keep the annual results still in the environment
sites_mos_polys_months <- sites_mos_polys
sites_ham_polys_months <- sites_ham_polys
sites_had_polys_months <- sites_had_polys

# Apply the function on the datasets and replace the original shp dataframe
# This is to have GIS-ready shapefile to export
sites_mos_polys_months@data <- get_zonal_pct(mos_dbf_monthly_list)
sites_ham_polys_months@data <- get_zonal_pct(ham_dbf_monthly_list)
sites_had_polys_months@data <- get_zonal_pct(had_dbf_monthly_list)


# Save a new polygon shapefile

writeOGR(
  obj = sites_mos_polys_months,
  dsn = here::here("output/shp/perc_poly_mos_2018.shp"),
  layer = "perc_poly_mos_2018",
  driver = "ESRI Shapefile", overwrite_layer = TRUE
)

writeOGR(
  obj = sites_ham_polys_months,
  dsn = here::here("output/shp/perc_poly_ham_2018.shp"),
  layer = "perc_poly_ham_2018",
  driver = "ESRI Shapefile", overwrite_layer = TRUE
)

writeOGR(
  obj = sites_had_polys_months,
  dsn = here::here("output/shp/perc_poly_had_2018.shp"),
  layer = "perc_poly_had_2018",
  driver = "ESRI Shapefile", overwrite_layer = TRUE
)
