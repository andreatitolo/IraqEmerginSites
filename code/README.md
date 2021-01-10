# Code Folder
## Description

This folder contains two subfolders:
* GEE: Here there are three scripts (.js) to use directly in Google Earth Engine 
  * ```01-Landsat_annual_NDWI.js``` ---> This script generate annual NDWI composites using Landsat Images. The user can choose whether to use Landsat 5, 7 or 8.
  * ```02-Landsat_2_NDWI.js``` ---> A simpler version of the above, that include only Landsat 2 images for the Hamrin dam and all the necessary preprocessing steps.
  * ```03-Sentinel_annual_monthly_NDWI.js``` ---> A version of the 01 script but with Sentinel-2 specific functions and the chunks necessary to the monthly composites generation.
* R: Here there are 5 scripts (.R) to use in R/Rstudio.
  * ```00_rgee_NDWI.R``` ---> Script to process NDWI composites. Thi script integrates the RGEE 01 and 03 scripts, it allows user to change preferences (satellite types, area, cloud filter, images display, target gdrive folder and way of downloading) at the beginning of the script, so that it can be run multiple times without scrolling too much far down the script.
  * ```01_rgee_NDWI_L2.R``` ---> A simpler version of the 00 script, focused only on the processing of Landsat 2 images.
  * ```02_pixel_analysis.R``` ---> This script extract pixel values at point location from a series of satellite images and generates new point shapefiles. Make sure to have the images in the right location or to change paths accordingly. The function used in this script is available in the ```get_pixel_values.R``` script in the **functions** subfolder.
  * ```03_zonal_histogram.R``` ---> This script uses the [qgisprocess](https://github.com/paleolimbot/qgisprocess.git) package to use the zonal histogram qgis algorithm in order to count the number of unique pixel values inside a polygon feature. The script provide a reclassification with a matrix beforehand, saving the reclassified images in the raster subfolders. The functions used are sourced from the ```get_zonal_histo_pct.R``` script.
  **In order to use the qgis_process tool, a version of qgis 3.14 or higher must be installed on your system.** Note that {qgisprocess} is still underdevelopment and the entire qgis_process tool is still in its early phases (https://github.com/qgis/QGIS/pull/34617). 
  * ```04_merge_zonal_histogram_results.R``` ---> A processing script that merge the outputs of the 03_zonal_histogram script, exporting new polygon shapefiles. It is separated from the last script as it requires different packages and to keep the 03 script cleaner. The function used is sourced from the ```get_zonal_histo_pct.R``` script.

  More information are available in the scripts as comments.

