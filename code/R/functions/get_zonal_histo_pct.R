# THESE FUNCTIONS ARE SUPPOSED TO BE USED WITH THE 03_zonal_histogram.R SCRIPT.


# batch_reclass_and_save function -----------------------------------------

# This function was adapted from 
# https://stackoverflow.com/questions/52750561/how-to-reclassify-a-batch-of-rasters-in-r
# It reads raster files from a supplied directory and reclassify them, then save them to a local folder
# Arguments:
  # raslist is a is a character vector containing file names of the rasters that needs to be reclassified.
  # raster_path s a character vector indicating the folder in which the raster files 
  # are stored, accepts relative paths.
  # rclmat is a reclassification matrix for the reclassify function to work
  # outpath is a character vector indicating the target folder where to save 
  # the reclassified rasters, accepts relative paths.

batch_reclass_and_save <- function(raslist, raster_path, rclmat, outpath){
  
  for (i in 1:length(raslist)) {
    #read in raster
    r <- raster(file.path(raster_path, raslist[i]))
    
    #perform the reclassifcation
    rc <- reclassify(r, rclmat)
    
    #write each reclass to a new file 
    writeRaster(rc, filename = paste0(outpath, "r_", 
                                      raslist[i]), format="GTiff", overwrite=TRUE)
    
    print(rc)
  }
  
  cat("====== DONE ======")
}


# get_zonal_histogram function --------------------------------------------

# This function calculates zonal histogram algorithm from monthly and annual rasters
# The aim of this function is to loop through a list of rasters and apply the zonal histogram algorithm
# The zonal histogram is a QGIS algorithm accesed through the {qgisprocess} package

# Arguments:
  # polys is a polygon shapefile (class SpatialPolygonsDataframe) containing one ore more polygons
  # raster_files is a character vector containing file names of reclassified rasters
  # raster_path is a character vector indicating the folder in which the raster files 
  # are stored, accepts relative paths.
  # area_filter is a character vector indicating the abbreviation for the study area
  # to which the rasters and the polygons pertain.
  # out_path is a character vector indicating the target folder where to save 
  # the reclassified rasters, accepts relative paths.

# The function returns a series of shapefiles, one for each raster used,
# containing the count of unique pixel values inside one or more polygons.

get_zonal_histo <- function(polys, raster_files, raster_path, area_filter, out_path) {
  ras_filtered <- grep(area_filter, raster_files, value = TRUE) # filter to use only the rasters of the chosen area

  area <- substring(ras_filtered[[1]], first = 3, last = 5) # character vector for programmatically naming later

  # if there is only one 2018 date among the rasters, we are dealing with the annual series of rasters
  if (length(grep("2018", ras_filtered, value = TRUE)) <= 1) {
    dates <- paste0(substring(ras_filtered, first = 12, last = 15)) # obtain the dates from the file names
  } else {
    dates <- tolower(month.abb) # If we are dealing with the montly series, get the dates as abbreviated months names
  }

  polys_sf <- sf::st_as_sf(polys) # convert the SpatialPolygonDataFrame to an sf object for qgisprocess to work properly
  shp_list <- list() # empty list where to store the outcome of the loop

  for (i in 1:length(ras_filtered)) {
    ras_files <- list.files(raster_path, pattern = paste0(area_filter, "*tif$"), 
                            full.names = TRUE, recursive = FALSE) # INPUT_RASTER needs the entire path to the files
    shp_list[[i]] <- zonal_histogram(
      INPUT_RASTER = ras_files[[i]],
      RASTER_BAND = 1,
      INPUT_VECTOR = polys_sf,
      COLUMN_PREFIX = paste0(dates[i], "_"),
      OUTPUT = file.path(out_path, paste0(area, "_", dates[[i]], ".shp"))
    )
    print(shp_list[[i]])
  }

  cat("====== DONE ======")
}



# get_zonal_pct function --------------------------------------------------

# This function is aimed at manipulating data resulted from the zonal histogram script

# The aim is to merge all the files  from the zonal histogram in a wide format
# This function uses some different packages to achieve its result,
# the needed libraries are loaded in the main script (janitor, dplyr, magrittr).
# The function takes one argument, which has to be a list of dataframes
# The first four pipes convert the numerical fields of all the data frame in the
# list into percentages and then it merge them column-wise.
# The filter with "select()" remove any possible duplicate fields, e.g.  FID and NODATA
# The last two pipes are meant to rename column names in a more readable way,
# but still within the limit of the shapefile fields length.

get_zonal_pct <- function(x) {
  a <- x %>%
    adorn_percentages() %>%
    bind_cols() %>%
    select(-contains(c("fid", "N", "site_name", "."), ignore.case = FALSE)) %>%
    mutate_if(is.numeric, ~ . * 100) %>%
    bind_cols(select(x[[1]], "site_name"), .) %>%
    adorn_rounding(digits = 0) %>% # Automatically applies on numerical fields only
    mutate_if(is.numeric, as.integer) %>%
    set_colnames(gsub(
      x = sub("X", "", colnames(.), fixed = TRUE),
      pattern = "*_0", replacement = "_pct_e"
    )) %>%
    set_colnames(gsub(
      x = colnames(.),
      pattern = "*_1", replacement = "_pct_s"
    ))


  print(a)
}
