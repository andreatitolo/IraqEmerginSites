# THESE FUNCTION IS SUPPOSED TO BE USED WITH THE 02_pixel_analysis.R SCRIPT.

# get_annual_pixel_values_function ----------------------------------------

# This function extracts pixel value at point location from a series of rasters
# It uses the "extract" function from the {raster} package to retrieve pixel values
# The function takes two arguments:
  # shp is apoint shapefile (class SpatialPointDataFrame)
  # raster_files is a character vector containing the files the path to the 
  # raster files and their names.

# The function returns a data frame containing pixel values of each raster at each point location
# plus four columns (NumEmers, NeverAff, AlwaysSub, EmergOnce) resulted from quantitative analysis of the pixel values.


get_pixel_values <- function(shp, raster_files) {
  # Coordinates are needed to extract px values
  sites_coords <- shp@coords[, 1:2]
# If there is no "-01" character in raster_files, we are dealing with the annual series of rasters
  if (!grepl("*.-01", head(raster_files, n = 1), ignore.case = FALSE)) {

    # Create two stacks because Landsat and Sentinel images have different pixel size
    landsat_stack <- raster::stack(grep("L", raster_files, value = TRUE))
    sentinel_stack <- raster::stack(grep("S2", raster_files, value = TRUE))

    landsat_values <- round(raster::extract(landsat_stack, sites_coords), 5)
    sentinel_values <- round(raster::extract(sentinel_stack, sites_coords), 5)

    site_names <- data.frame(shp@data$site_name) # extract site names as data frame to bind the results
    sites_px <- cbind(site_names, landsat_values, sentinel_values)

    # Make sure that the column names follow the year and satellite of the input raster files
    colnames(sites_px) <- c("site_name", substring(names(sites_px[, 2:length(sites_px)]), 10, 16))

    # Chunks related to the quantitative analysis of the columns
    # The number of emersions is equal to the times a site registered a pixel value < 0
    # Start the count from the third column to ensure to count the year after the construction of the dam
    # The if clause is needed because the Mosul dam was filled in 1986 and not in 1985 as the Haditha dam
    if ("Ger Matbakh" %in% sites_px$site_name) {
      sites_px$NumEmers <- as.integer(rowSums(sites_px[c(4:length(sites_px))] < 0, na.rm = TRUE))
    } else {
      sites_px$NumEmers <- as.integer(rowSums(sites_px[c(3:length(sites_px))] < 0, na.rm = TRUE))
    }
    
    # If the number of emersions is equal or larger than the number of counted columns (33) then the site was always out of the water
    # A Nested ifelse is necessary because the Hamrin dam was constructed earlier
    # Both Atiqeh and Razuk emerged more than 33 times, and the following ensure they are not erroneously counted as Never Affected
    sites_px$NeverAff <- ifelse(sites_px$NumEmers >= 33,
      ifelse(sites_px$site_name == "Tell Atiqeh", 0,
        ifelse(sites_px$site_name == "Tell Razuk", 0, 1)
      ), 0
    )
    sites_px$NeverAff <- as.integer(sites_px$NeverAff)
    sites_px$AlwaysSub <- as.integer(ifelse(sites_px$NumEmers == 0, 1, 0)) # if the number of emersion is zero,  the site was always submerged

    sites_px$EmergOnce <- as.integer(ifelse(sites_px$NeverAff != 1, sites_px$AlwaysSub != 1, 0))
    
  } else if (grepl("*.-01", head(raster_files, n = 1), ignore.case = FALSE)) { 
    rasterstack <- stack(raster_files)

    # Extract site names as data frame to bind the results
    site_names <- data.frame(shp@data$site_name)

    sites_px <- round(raster::extract(rasterstack, sites_coords), 5)

    sites_px <- cbind(site_names, sites_px)

    mycolumns <- c("site_name", paste0("2018_", tolower(month.abb)))
    colnames(sites_px) <- mycolumns


    sites_px$NumEmers <- as.integer(rowSums(sites_px[c(2:13)] < 0, na.rm = TRUE))
    sites_px$NeverAff <- as.integer(ifelse(sites_px$NumEmers == 12, 1, 0))
    sites_px$AlwaysSub <- as.integer(ifelse(sites_px$NumEmers == 0, 1, 0))
    sites_px$EmergOnce <- as.integer(ifelse(sites_px$NeverAff != 1, sites_px$AlwaysSub != 1, 0))
  }

  print(sites_px)
}
