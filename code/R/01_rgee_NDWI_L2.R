# R version: 4.03 
# rgee version: 1.0.6 
# python version: 3.8.6 
# numpy_version: 1.19.4 
# earthengine_api version: 0.1.235


# Description -------------------------------------------------------------

# This simple script will produce a single mosaic of Landsat 2 images generating
# an NDWI composite for the year 1975. The target region is the Hamrin dam only.
# The image is then downloaded in Google Drive.

# Be aware that Landsat 2 scenes are provided in DN values, so they need to be 
# converted to TOA reflectance to generate the NDWI.


# Initial Configuration ---------------------------------------------------


library(rgee)
# Initialize rgee
ee_Initialize(email = "titoloandrea@gmail.com", drive = TRUE, gcs = FALSE)
gdrive_folder <- "rgeeIraqEmerginSites"

study_region <- ee$Geometry$Polygon(coords = list(
  c(44.8212486109187, 34.3825352662983),
  c(44.8212486109187, 34.0338727840116),
  c(45.20851667732495, 34.0338727840116),
  c(45.20851667732495, 34.3825352662983)
))



# Functions and Processing ------------------------------------------------



# Function to mask clouds from the QA band in Landsat images
cloudfunction <- function(image) {
  qa <- image$select("BQA")
  cloudBitMask <- ee$Number(2)$pow(4)$int()
  mask <- qa$bitwiseAnd(cloudBitMask)$eq(0)
  return(image$updateMask(mask))$
    select("B.*")$
    copyProperties(image, ("system:time_start"))
}



# Process the image and sort the collection according to the cloud coverage
L2_DN <- ee$ImageCollection("LANDSAT/LM02/C01/T2")$
  filter(ee$Filter$date('1975-01-01', '1975-12-30'))$
  filter(ee$Filter$lt("CLOUD_COVER", 0.1))$
  filterBounds(study_region)$
  map(cloudfunction)$
  sort('CLOUD_COVER')


# Get the first image (least cloudy), there is no need to mosaic in this case since we
L2_first <- ee$Image(L2_DN$first())

# Convert the DN data to top-of-atmosphere reflectance and clip to your geometry
# See https://developers.google.com/earth-engine/guides/landsat#at-sensor-radiance-and-toa-reflectance
L2<- ee$Algorithms$Landsat$TOA(L2_first)$clip(study_region)
ee_print(L2)

green <- L2$select('B4')
swir <- L2$select('B7')
ndwi_L2 <- green$subtract(swir)$divide(green$add(swir))$rename('NDWI')


# Visualization -----------------------------------------------------------


ndwiParams = list(min = -1, max = 1, palette = c('#a52a2a', '#ffffff', '#0000ff'))
Map$centerObject(study_region, 10) # We centre the map on our study area with a set zoom
Map$addLayer(ndwi_L2, ndwiParams,'NDWI_L2_image')


# Exporting ---------------------------------------------------------------


# Move results from Earth Engine to Drive
task_img <- ee_image_to_drive(
  image = ndwi_L2,
  fileFormat = "GEO_TIFF",
  folder = "rgee_landsat_2",
  region = study_region,
  fileNamePrefix = "ham_1972_NDWI_L2"
)

task_img$start()
ee_monitoring(task_img)
