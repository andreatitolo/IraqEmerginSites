# Data Folder

## Description
The data folder is divided in two subfolders:
* rasters:
    * 2018_Monthly: This folder should contain monthly Sentinel-2 NDWI composites of the year 2018. Due to their size the images could not be uploaded to github, but they can be downloaded from figshare [HERE](https://figshare.com/s/ff067df594ce72300409)
        * reclassified: This folder contains the reclassified monthly NDWI images generated with the 03_zonal_histogram script. 
    * annual: This folder should contain annual Landsat 5, 7, 8 and Sentinel-2 NDWI composites covering from 1984 to 2019. Due to their size the images could not be uploaded to github, but they can be downloaded from figshare [HERE](https://figshare.com/s/9c749336fb27342a4f18)
        * reclassified: This folder contains the reclassified annual NDWI images generated with the 03_zonal_histogram script. 
* shp: here are stored the raw shapefiles used for the analysis, i.e. points shapefiles and polygons shapefiles of archaeological sites.
    * the study area subfolder contains the shapefiles of the study areas limits for each reservoir. These were generated from the Google Earth Engine geometry and were used to crop and mosaic the satellite images.