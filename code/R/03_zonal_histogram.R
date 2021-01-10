# Script to calculate the zonal histogram from annual and monthly rasters over
# a series of Polygon shapefiles

# More information on the algorithm are available at:
# https://docs.qgis.org/3.10/en/docs/user_manual/processing_algs/qgis/rasteranalysis.html#zonalhistogram
# the {qgisprocess} package is used here as an interface with the QGIS API
# it allows to run qgis algorithms from within R
# The original NDWI rasters need to be reclassified using a matrix before using the algorithm

source("./code/R/functions/get_zonal_histo_pct.R")

# Annual Zonal Histogram  -------------------------------------------------

library(raster)
library(rgdal)
library(here)
library(sf)

# remotes::install_github("paleolimbot/qgisprocess")
library(qgisprocess)

# Get details on the qgisprocess path
# qgis_configure()

# Get information on the desired algorithm
# note how the algorithm takes as raster input the PATH to a raster file
qgis_show_help("native:zonalhistogram")


# Create an R function from the qgis function
zonal_histogram <- qgis_function("native:zonalhistogram")


# Load the data
sites_mos_polys <- readOGR(here::here("data/shp", "sites_mosul_polys.shp"), stringsAsFactors = FALSE)
sites_ham_polys <- readOGR(here::here("data/shp", "sites_hamrin_polys.shp"), stringsAsFactors = FALSE)
sites_had_polys <- readOGR(here::here("data/shp", "sites_haditha_polys.shp"), stringsAsFactors = FALSE)



# list files (in this case raster TIFFs)
all_raster_files <- list.files(here::here("data/rasters/annual"),
  pattern = "*.tif$",
  recursive = FALSE, full.names = FALSE
)

# Create different lists for each area if needed

# mos_files <- grep("mos.", all_raster_files, value = TRUE)

# ham_files <- grep("ham.", all_raster_files, value = TRUE)

# had_files <- grep("had.", all_raster_files, value = TRUE)


# Set rules and create a reclassification matrix (2x3)
my_rules <- c(-1, 0, 0, 0, 1, 1)
reclmat <- matrix(my_rules, ncol = 3, byrow = TRUE)

# Since the zonal histogram algorithm requires a path to a raster file
# we need to save to a local folder the results of the reclassification
batch_reclass_and_save(
  raslist = all_raster_files,
  raster_path = "data/rasters/annual/",
  rclmat = reclmat,
  outpath = "data/rasters/annual/reclassified/"
)

# List the reclassified rasters
r_raster_files <- list.files(here::here("data/rasters/annual/reclassified/"),
  pattern = "*.tif$",
  recursive = TRUE, full.names = FALSE
)


# Apply the function to generate new shapefiles with the zonal histogram algorithm
# Do it separately for each are to have correct results, otherwise there will be 
# overlapping and NULL values if the areas and the rasters are mixed without filtering
# The area filter variable is used as filter for the raster files and for naming
# more details are available in the sourced script

get_zonal_histo(
  polys = sites_mos_polys,
  raster_files = r_raster_files,
  raster_path = "data/rasters/annual/reclassified/",
  area_filter = "mos.",
  out_path = "./output/shp/annual"
)

get_zonal_histo(
  polys = sites_ham_polys,
  raster_files = r_raster_files,
  raster_path = "data/rasters/annual/reclassified/",
  area_filter = "ham.",
  out_path = "./output/shp/annual"
)

get_zonal_histo(
  polys = sites_had_polys,
  raster_files = r_raster_files,
  raster_path = "data/rasters/annual/reclassified/",
  area_filter = "had.",
  out_path = "./output/shp/annual"
)

# Monthly Zonal Histogram -------------------------------------------------

# Load the data if not already loaded
sites_mos_polys <- readOGR(here::here("data/shp", "sites_mosul_polys.shp"), stringsAsFactors = FALSE)
sites_ham_polys <- readOGR(here::here("data/shp", "sites_hamrin_polys.shp"), stringsAsFactors = FALSE)
sites_had_polys <- readOGR(here::here("data/shp", "sites_haditha_polys.shp"), stringsAsFactors = FALSE)

# List the monthly raster files
months_raster_files <- list.files(here::here("data/rasters/2018_monthly"),
  pattern = "*.tif$",
  recursive = FALSE
)


# Set rules and create a reclassification matrix (2x3)
my_rules <- c(-1, 0, 0, 0, 1, 1)
reclmat <- matrix(my_rules, ncol = 3, byrow = TRUE)

# Since the zonal histogram algorithm requires a path to a raster file
# we need to save to a local folder the results of the reclassification
batch_reclass_and_save(
  raslist = months_raster_files,
  raster_path = "data/rasters/2018_monthly/",
  rclmat = reclmat,
  outpath = "data/rasters/2018_monthly/reclassified/"
)


# List the reclassified rasters
r_monthly_raster_files <- list.files(here::here("data/rasters/2018_monthly/reclassified/"),
  pattern = "*.tif$",
  recursive = TRUE, full.names = FALSE
)

# Apply the function to generate new shapefiles with the zonal histogram algorithm
# Do it separately for each are to have correct results, otherwise there will be 
# overlapping and NULL values if the areas and the rasters are mixed without filtering
# The area filter variable is used as filter for the raster files and for naming
# more details are available in the sourced script

get_zonal_histo(
  polys = sites_mos_polys,
  raster_files = r_monthly_raster_files,
  raster_path = "data/rasters/2018_monthly/reclassified/",
  area_filter = "mos.",
  out_path = "./output/shp/monthly"
)

get_zonal_histo(
  polys = sites_ham_polys,
  raster_files = r_monthly_raster_files,
  raster_path = "data/rasters/2018_monthly/reclassified/",
  area_filter = "ham.",
  out_path = "./output/shp/monthly"
)

get_zonal_histo(
  polys = sites_had_polys,
  raster_files = r_monthly_raster_files,
  raster_path = "data/rasters/2018_monthly/reclassified/",
  area_filter = "had.",
  out_path = "./output/shp/monthly"
)

