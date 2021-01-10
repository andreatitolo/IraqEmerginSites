# R version: 4.03 
# rgee version: 1.0.6 
# python version: 3.8.6 
# numpy_version: 1.19.4 
# earthengine_api version: 0.1.235


# Description -------------------------------------------------------------


# The aim of the script is to produce an ImageCollection of NDWI Satellite
# images, with one image mosaic per year or one image mosaic per month. 
# The script will also export the resulting ImageCollection, letting the user
# choose whether to export the images on google drive or to a local folder.
# Each image will be named in a machine readable format with the study area,
# the type of image and the date. 
# This script uses the {rgee} package (Aybar et al., (2020) https://doi.org/10.21105/joss.02272)
# please see the instruction to install and use rgee: https://github.com/r spatial/rgee

# In the "Initial Configuration section, the user will find all the options to
# edit, in this way the other sections can be run without any further edits.
# If more in depth changes are needed, be sure to look at the other sections as well.

# Change also the email inside ee_intialize() accordingly.


# All the images are exported following a naming convention: "area_image_type
# YYYY_satellite" or "area_image_type YYYY-MM_satellite" for the monthly
# composites.
# Once the export task is completed, it will take some minutes for the images to show up in GDrive
# The local download option will take longer depending on the image size
# make sure to have some space on Google Drive or the process might not complete

# The function for generating list of dates and the one for acquiring one
# image per year is adapted from
# https://gis.stackexchange.com/questions/269313/mapping-over-list-of-dates-in-google-earth-engine

# Initial Configuration ---------------------------------------------------

library(rgee)
# Initialize rgee
ee_Initialize(email = "titoloandrea@gmail.com", drive = TRUE, gcs = FALSE)

# ee_check()
# ee_check_credentials()
# ee_user_info()


# Choose which method to use for exporting the images (DRIVE, LOCAL)
# see https://r-spatial.github.io/rgee/reference/ee_imagecollection_to_local.html#details
drive <- TRUE
local_drive <- FALSE # Slower, depending on the images.

# Which area do we want to use? Set to TRUE only one at a time
Mosul <- TRUE
Hamrin <- FALSE
Haditha <- FALSE

# Choose which satellite we want to use
# The option to generate monthly satellite images can be set here
# Select only one at a time.
L5 <- TRUE
L7 <- FALSE
L8 <- FALSE
S2 <- FALSE
monthly_S2 <- FALSE

# Set the desired cloud filter value
# Careful, very low cloud filter values obviously lead to fewer images
cloud_filter_value <- 0.1

# Choose the name of the folder to store the images exported when drive = TRUE
# Local folder is for when local_drive is set to TRUE
gdrive_folder <- "rgeeIraqEmerginSites"

# Do you want to limit the collection to a certain amount of images?
# Might be useful for testing purpose
limit <- FALSE
limit_num <- 5

# Display the imageCollection in an interactive map? 
# This may be slower depending on the number of images
display <- TRUE


# Variable Definition -----------------------------------------------------


# Generate geometries according to the chosen area
# Generate also a string useful in naming the images later

if (Mosul) {
  
  study_region <- ee$Geometry$Polygon(coords = list(
    c(42.351434036097544, 37.007772518496346),
    c(42.351434036097544, 36.55902574320424),
    c(43.032586379847544, 36.55902574320424),
    c(43.032586379847544, 37.007772518496346)
  ))

  area <- ee$String("mos_NDWI_")
  
} else if (Hamrin) {
  
  study_region <- ee$Geometry$Polygon(coords = list(
    c(44.8212486109187, 34.3825352662983),
    c(44.8212486109187, 34.0338727840116),
    c(45.20851667732495, 34.0338727840116),
    c(45.20851667732495, 34.3825352662983)
  ))

  area <- ee$String("ham_NDWI_")
  
} else if (Haditha) {
  
  study_region <- ee$Geometry$Polygon(coords = list(
    c(41.575724127263584, 34.563088447300345),
    c(41.575724127263584, 34.08675370370142),
    c(42.501322271794834, 34.08675370370142),
    c(42.501322271794834, 34.563088447300345)
  ))


  area <- ee$String("had_NDWI_")
  
}


# Variable definition according to the chosen satellite
# For each choice we define the ImageCollection, the bands to use to generate the NDWI,
# a string identifying the satellite (useful in the image naming later)
# and start and end dates (unique to each satellite).
# Please refer to https://www.usgs.gov/media/images/landsat-missions-timeline
# for information on periods of activity and decommision of each satellite.
# The start variable set the starting point and the end variable determine how much
# the function needs to advance from the start variable.

if (L5) {
  
  BaseColl <- ee$ImageCollection("LANDSAT/LT05/C01/T1_TOA")
  
  ndwi_bands <- c("B2", "B5")
  
  sensor <- ee$String("_L5")
  
  start <- ee$Date$fromYMD(1984, 01, 01)
  end <- ee$List$sequence(0, 14)
  
} else if (L7) {
  
  BaseColl <- ee$ImageCollection("LANDSAT/LE07/C01/T1_TOA")
  
  ndwi_bands <- c("B2", "B5")
  
  sensor <- ee$String("_L7")
  
  start <- ee$Date$fromYMD(1999, 01, 01)
  end <- ee$List$sequence(0, 13)
  
} else if (L8) {
  
  BaseColl <- ee$ImageCollection("LANDSAT/LC08/C01/T1_TOA")
  
  ndwi_bands <- c("B3", "B6")
  
  sensor <- ee$String("_L8")
  
  start <- ee$Date$fromYMD(2013, 01, 01)
  end <- ee$List$sequence(0, 6)
  
} else if (S2) {
  
  BaseColl <- ee$ImageCollection("COPERNICUS/S2")
  
  ndwi_bands <- c("B2", "B11")
  
  sensor <- ee$String("_S2")
  
  start <- ee$Date$fromYMD(2015, 01, 01)
  end <- ee$List$sequence(0, 4)
  
} else if (monthly_S2) {
  
  BaseColl <- ee$ImageCollection("COPERNICUS/S2")
  
  ndwi_bands <- c("B2", "B11")
  
  sensor <- ee$String("_S2")
  
  start <- ee$Date$fromYMD(2018, 01, 01)
  end <- ee$List$sequence(0, 11)
  
}





# Functions Definition -----------------------------------------------------



# Function to generate a list of dates over which we will map the image collection function
# Use ee_utils_pyfunc when mapping over a ee_List object
# See https://r-spatial.github.io/rgee/articles/considerations.html#the-map-message-error
# The monthly image collection require a different variable inside the "advance" function
# thus it is separated from the main one and will run only if monthly_S2 == TRUE

startDates <- end$map(ee_utils_pyfunc(
  function(x) start$advance(x, "year")
))


if (monthly_S2) {
  
  startDates <- end$map(ee_utils_pyfunc(
    function(x) start$advance(x, "month")
  ))
  
}


# Programmatically select functions and variables specific to each satellite
# Landsat and Sentinel have two different cloud masking function
# The attribute identifying the amount of cloud cover is also different 
# The pixel scale is set here and it is useful when exporting each image

if (grepl("LANDSAT", toString(BaseColl), ignore.case = TRUE)) {

  # Function to mask clouds from the QA band in Landsat images
  cloudfunction <- function(image) {
    qa <- image$select("BQA")
    cloudBitMask <- ee$Number(2)$pow(4)$int()
    mask <- qa$bitwiseAnd(cloudBitMask)$eq(0)
    return(image$updateMask(mask))$
      select("B.*")$
      copyProperties(image, ("system:time_start"))
  }

  cloud_filter <- ee$Filter$lt("CLOUD_COVER", cloud_filter_value)

  px_scale <- 30
  
} else if (grepl("COPERNICUS", toString(BaseColl), ignore.case = TRUE)) {

  # Function to mask clouds from the QA band in Sentinel images
  cloudfunction <- function(image) {
    QA60 <- image$select("QA60")
    return(image$updateMask(QA60$lt(1)))
  }

  cloud_filter <- ee$Filter$lt("CLOUDY_PIXEL_PERCENTAGE", cloud_filter_value)

  px_scale <- 10
  
}


# Function to generate and NDWI band using the shortcut function
# see https://developers.google.com/earth-engine/tutorials/tutorial_api_06
getNDWI <- function(img) {
  NDWI <- img$normalizedDifference(ndwi_bands)$rename("NDWI")
  return(NDWI)
}


# Function to generate NDWI mosaics for each year, steps:
# Get a starting date from the object that we are going to pass to the function
# Get an end range for each step advancing by: 1 year
# Creates a date range, according to the start and end layer
# Create a name property for each image from the variables we set before and the starting year date 
# Select the dataset as ImageCollection
# Filter the collection for images within our date ranges
# Filter the collection for images within our study region
# Filter for the percentage of cloud cover set before
# Map the cloud function chosen before
# Map the NDWI function created before, this will return the NDWI band of each image in the collection
# Clip the images to our study region
# Apply the median reducer to mosaic the images of each year and set the variable name as a property of the images.

yearmap <- function(m){
  start <- ee$Date(m) 
  end <- ee$Date(m)$advance(1,"year")
  date_range <- ee$DateRange(start,end)
  name <- area$cat(start$format("YYYY"))$cat(sensor)
  ImgYear <- BaseColl$
    filterDate(date_range)$
    filterBounds(study_region)$
    filter(cloud_filter)$
    map(cloudfunction)$
    map(getNDWI)$
    map(function(img){return(img$clip(study_region))})
  return(ImgYear$median()$set("name",name))
}


# This is a slightly modified version of the above
# Date ranges are within a month interval
# The name property will show the month and nnot only the year

if (monthly_S2) {
  
  yearmap <- function(m){
    start <- ee$Date(m)
    end <- ee$Date(m)$advance(1,"month")
    date_range <- ee$DateRange(start,end)
    name <- area$cat(start$format("YYYY-MM"))$cat(sensor)
    ImgYear <- BaseColl$
      filterDate(date_range)$
      filterBounds(study_region)$
      filter(cloud_filter)$
      map(cloudfunction)$
      map(getNDWI)$
      map(function(img){return(img$clip(study_region))})
    return(ImgYear$median()$set("name",name))
  }
  
}


# Processing --------------------------------------------------------------


# Map the function over the list of dates created above
list_of_images <- startDates$map(ee_utils_pyfunc(yearmap))


# Transform the list of images to an ImageCollection to batch export them
ImgColl <- ee$ImageCollection(list_of_images)

# # If needed, get information on the first image
# ee_print(ImgColl$first())


# Visualisation -----------------------------------------------------------


if (display) {
  
  # ndwiParams = list(min = -1, max = 1, palette = c('brown', 'white', 'blue'))
  ndwiParams = list(min = -1, max = 1, palette = c('#a52a2a', '#ffffff', '#0000ff'))
  img_name <- ImgColl$aggregate_array('name')$getInfo()
  
  Map$centerObject(study_region, zoom = 10)
  Map$addLayers(eeObject = ImgColl, visParams = ndwiParams, name = img_name, legend = TRUE, shown = FALSE)
  
}

# Export ------------------------------------------------------------------



# OPTIONAL: limit the Collection size and print info on its size
if (limit) {
  
  ExpColl <- ImgColl$limit(limit_num)
  cat("Limited Collection Size: ", ExpColl$size()$getInfo())
  
} else {
  
  ExpColl <- ImgColl
  cat("Collection Size: ", ExpColl$size()$getInfo())
  
}




# Export to Drive ---------------------------------------------------------

if (drive) {
  
# Count the number of images in the collection and convert them to a list
# the list will make possible to extract single images from the collection during the loop
  count <- ExpColl$size()$getInfo()
  ExpColl_list <- ExpColl$toList(count)
  
  # Loop to output each image
  for (index in seq_len(count)) {
    image <- ee$Image(ExpColl_list$get(index - 1))
    date <- ee_get_date_img(image)
    name <- ee$String(image$get('name'))$getInfo()
    print(name)
    task <- ee$batch$Export$image$toDrive(
      image,
      name,
      scale = px_scale,
      maxPixels = 1e9,
      folder = gdrive_folder,
      region = study_region
    )
    task$start()
    # ee_monitoring_test()
  }
  task$status()
}

# Export to Local Folder - Drive Method -----------------------------------

if (local_drive) {

  # Set the export folder and date/names variables
  count <- ExpColl$size()$getInfo()
  ExpColl_list <- ExpColl$toList(count)
  image <- ee$Image(ExpColl_list$get(0))
  names <- ee$String(image$get("name"))$getInfo()

  if (monthly_S2) {
    local_folder <- here::here("data/rasters/2018_monthly")
  } else {
    local_folder <- here::here("data/rasters/annual")
  }


  # Using drive method
  ic_local <- ee_imagecollection_to_local(
    ic = ExpColl,
    region = study_region,
    scale = px_scale,
    dsn = file.path(local_folder, names),
    maxPixels = 1e9,
    via = "drive"
  )


  # Delete container (the folder in google drive created automatically)
  ee_clean_container(name = "rgee_backup", type = "drive")

  task$status()
  # Load the results as a RasterBrick Object
  raster::stack(ic_local)
}

