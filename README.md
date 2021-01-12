# IraqEmergingSites
# Use of Time-Series NDWI to Monitor Emerging Archaeological Sites: Case Studies from Iraqi Artificial Reservoirs

Inside this repository there are:
* [Data](https://github.com/andreatitolo/IraqEmergingSites/tree/master/data) for forthcoming paper "*Use of Time-Series NDWI to Monitor Emerging Archaeological Sites: Case Studies from Iraqi Artificial Reservoirs*".
  * Forthcoming paper in xxxxx (xxx 2021)
  * https://doi.org/xxxxx
  * NOTE: the present digital archive  also  include the datasets relative to the Haditha dam. This dataset is composed simply by a point and polygon shapefile with the site names, but a more in-depth dataset will be published separately in forthcoming publications.
  * Additional NOTE: NDWI Raster data as generated in Google Earth Engine/ Rscripts are not present in this repository due to their size, but they can be downloaded from [HERE](https://figshare.com/s/9c749336fb27342a4f18) (annual NDWI) and [HERE](https://figshare.com/s/ff067df594ce72300409) (2018 monthly NDWI). Alternatively they can be generated using the GEE script or the R scripts in this repository (this however may require additional trial and error with the cloud cover percentage filter, see the paper for more details).
  * When downloading the images from figshare, **make sure to place them in their respective folder**, i.e.:
    * Annual NDWI composites ---> data/rasters/annual 
    * 2018 Monthly NDWI composites ---> data/rasters/2018_monthly
* Google Earth Engine (GEE) scripts, available in the relative [subfolder](https://github.com/andreatitolo/IraqEmergingSites/tree/master/code/GEE), used to generate annual and monthly composites used in the analysis:  
  * A main script for Landsat 5-8 and Sentinel-2 images.
  * A second script for Landsat 2 images.
* R code divided in five main scripts and two functions scripts, used to run the analysis, available in the [Script Subfolder](https://github.com/andreatitolo/IraqEmergingSites/tree/master/code/R).
* A QGIS Project (.qgz) with shapefile data already loaded with models to run the models embedded into the project itself. The qgis project is saved in QGIS Version 3.10.12, but the models and the project have been tested also in QGIS version 3.16.1.
* QGIS processing tools, in the [QGIS Subfolder](https://github.com/andreatitolo/IraqEmergingSites/tree/master/QGIS_models_scripts) :
  * Standalone qgis models as .model3 file
  * Same models as python scripts
  * An R script written for QGIS (.rsx file)

<details> 
  <summary>Repository Tree</summary> 

 (generated with https://github.com/xiaoluoboding/repository-tree)
 
```
├─ QGIS_models_scripts
│  ├─ Get Pixel Values (Two Raster Inputs).model3
│  ├─ Get Pixel Values (Two Raster Inputs).py
│  ├─ JoinZonalHistogramOutput.rsx
│  ├─ README.md
│  ├─ Reclassify and Get Zonal Histogram (Run as Batch).model3
│  └─ Reclassify and Get Zonal Histogram (Run as Batch).py
├─ code
│  ├─ GEE
│  │  ├─ 01-Landsat_annual_NDWI.js
│  │  ├─ 02-Landsat_2_NDWI.js
│  │  ├─ 03-Sentinel_annual_monthly_NDWI.js
│  │  └─ README.md
│  ├─ R
│  │  ├─ functions
│  │  │  ├─ get_pixel_values.R
│  │  │  └─ get_zonal_histo_pct.R
│  │  ├─ 00_rgee_NDWI.R
│  │  ├─ 01_rgee_NDWI_L2.R
│  │  ├─ 02_pixel_analysis.R
│  │  ├─ 03_zonal_histogram.R
│  │  ├─ 04_merge_zonal_histogram_results.R
│  └─ README.md
├─ data
│  ├─ rasters
│  │  ├─ 2018_monthly
│  │  │  ├─ reclassified
│  │     │  ├─ Reclassified monthly rasters.tif
│  │  │  └─ README.md
│  │  └─ annual
│  │     ├─ reclassified
│  │     │  ├─ Reclassified annual rasters.tif
│  │     └─ README.md
│  ├─ shp
│  │  ├─ study_area
│  │  │  ├─ haditha_study_area.shp
│  │  │  ├─ hamrin_study_area.shp
│  │  │  ├─ mosul_study_area.shp
│  │  ├─ sites_haditha_points.shp
│  │  ├─ sites_haditha_polys.shp
│  │  ├─ sites_hamrin_points.shp
│  │  ├─ sites_hamrin_polys.shp
│  │  ├─ sites_mosul_points.shp
│  │  ├─ sites_mosul_polys.shp
│  └─ README.md
├─ output
│  └─ shp
│     ├─ annual
│     │  └─ README.md
│     └─ monthly
│        └─ README.md
├─ .gitignore
├─ IraqEmergingSites.Rproj
├─ IraqEmergingSites.qgz
└─ README.md
```
</details>

