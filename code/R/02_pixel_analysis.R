# Script to extract pixel values from annual and monthly rasters at point locations
# using point shapefiles


# Approximate running time for the script: 2 mins.

source("./code/R/functions/get_pixel_values.R")

# Annual Pixel Analysis ---------------------------------------------------


library(raster)
library(rgdal)
library(here)


# Load the data
sites_mos_points <- readOGR(here::here("data/shp", "sites_mosul_points.shp"), stringsAsFactors = FALSE)
sites_ham_points <- readOGR(here::here("data/shp", "sites_hamrin_points.shp"), stringsAsFactors = FALSE)
sites_had_points <- readOGR(here::here("data/shp/", "sites_haditha_points.shp"), stringsAsFactors = FALSE)


# List files (in this case raster TIFFs)
# Parameter "full.names" is set to TRUE because raster package doesn't like subfolders
all_raster_files <- list.files(here::here("data/rasters/annual"),
                               pattern = "*.tif$",
                               recursive = FALSE, full.names = TRUE
)



# Select those of interest
mos_raster_files <- grep("mos", all_raster_files, value = TRUE)
ham_raster_files <- grep("ham", all_raster_files, value = TRUE)
had_raster_files <- grep("had", all_raster_files, value = TRUE)



# Apply the sourced function to the points and the raster files
sites_mos_points_px <- get_pixel_values(sites_mos_points, mos_raster_files)
sites_ham_points_px <- get_pixel_values(sites_ham_points, ham_raster_files)
sites_had_points_px <- get_pixel_values(sites_had_points, had_raster_files)


# Replace the results in the table data of the original SpatialPointsDataFrame
# In this way we can export a new shapefile to use directly in GIS
# It will also avoid passing through the creation of another spatial object
sites_mos_points@data <- sites_mos_points_px
sites_ham_points@data <- sites_ham_points_px
sites_had_points@data <- sites_had_points_px


writeOGR(
  obj = sites_mos_points,
  dsn = here::here("output/shp/sites_mosul_points_px.shp"),
  layer = "sites_mosul_points_px",
  driver = "ESRI Shapefile", overwrite_layer = TRUE
)

writeOGR(
  obj = sites_ham_points,
  dsn = here::here("output/shp/sites_hamrin_points_px.shp"),
  layer = "sites_hamrin_points_px",
  driver = "ESRI Shapefile", overwrite_layer = TRUE
)

writeOGR(
  obj = sites_had_points,
  dsn = here::here("output/shp/sites_haditha_points_px.shp"),
  layer = "sites_haditha_points_px",
  driver = "ESRI Shapefile", overwrite_layer = TRUE
)


# Monthly Pixel Analysis ----------------------------------------------



# Load the data, we are using the point shapefiles generated before
# This is to exclude the sites that have never been affected by the lakes
sites_mos_points <- readOGR(here::here("output/shp/sites_mosul_points_px.shp"), stringsAsFactors = FALSE)
sites_ham_points <- readOGR(here::here("output/shp/sites_hamrin_points_px.shp"), stringsAsFactors = FALSE)
sites_had_points <- readOGR(here::here("output/shp/sites_haditha_points_px.shp"),stringsAsFactors = FALSE)


# Select only sites that have not been always out of the water
# which is the case when "NeverAff" == 1
fltr_sites_mos_points <- sites_mos_points[sites_mos_points@data$NeverAff != 1, ]
fltr_sites_ham_points <- sites_ham_points[sites_ham_points@data$NeverAff != 1, ]
fltr_sites_had_points <- sites_had_points[sites_had_points@data$NeverAff != 1, ]




# List monthly raster files
months_raster_files <- list.files(here::here("data/rasters/2018_monthly"),
                                  pattern = "*.tif$",
                                  recursive = FALSE, full.names = TRUE
)

# create different lists for each area
mos_monthly_files <- grep("mos", months_raster_files, value = TRUE)
ham_monthly_files <- grep("ham", months_raster_files, value = TRUE)
had_monthly_files <- grep("had", months_raster_files, value = TRUE)


# Apply the sourced function to the points and the raster files
sites_mos_points_2018_px <- get_pixel_values(fltr_sites_mos_points, mos_monthly_files)
sites_ham_points_2018_px <- get_pixel_values(fltr_sites_ham_points, ham_monthly_files)
sites_had_points_2018_px <- get_pixel_values(fltr_sites_had_points, had_monthly_files)



# Replace the results in the table data of the filtered SpatialPointsDataFrame
# In this way we can export a new shapefile to use directly in GIS
fltr_sites_mos_points@data <- sites_mos_points_2018_px
fltr_sites_ham_points@data <- sites_ham_points_2018_px
fltr_sites_had_points@data <- sites_had_points_2018_px


# Export the results
writeOGR(
  obj = fltr_sites_mos_points,
  dsn = here::here("output/shp/sites_mosul_points_px_2018.shp"),
  layer = "sites_mosul_points_px_2018",
  driver = "ESRI Shapefile", overwrite_layer = TRUE
)
writeOGR(
  obj = fltr_sites_ham_points,
  dsn = here::here("output/shp/sites_hamrin_points_px_2018.shp"),
  layer = "sites_hamrin_points_px_2018",
  driver = "ESRI Shapefile", overwrite_layer = TRUE
)

writeOGR(
  obj = fltr_sites_had_points,
  dsn = here::here("output/shp/sites_haditha_points_px_2018.shp"),
  layer = "sites_haditha_points_px_2018",
  driver = "ESRI Shapefile", overwrite_layer = TRUE
)