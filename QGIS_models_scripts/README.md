# QGIS Models and Script Usage

These folder contains:
* Two qgis models as .Model3 files
* The same models exported as Python Scripts
* An R script (.rsx file) written for using within QGIS

## Usage
*A description of each model with more information can be found in the model help text (on the right tab when launching the model not as batch)*. **Load the rasters into the project for the models to work as intended.**
### QGIS Models
In order to use the models there are two options:  
* Open the IraqEmergingSites.qgz qgis project, which already has the models embedded -> on the processing panel, search for `Project models` -> select the model to run. 
* At the top of the processing toolbox, click the "Models" icon -> either `Open Existing model` or `Add model to toolbox`.  
* **Use the `Reclassify and Get Zonal Histogram` model as batch process** to generate shapefiles for more than one raster input (**RECOMMENDED**).
    * **IMPORTANT**: When using this model, in order to programmatically name the shapefile output, from the batch process interface, click the dropdown menu under "Polygons Zonal Histogram" and instead of "Automatic Fill" choose "Calculate with Expression". Once the expression window pops-up, insert the following expression:
    ```
    'C:/YOUR/PROJECT/DIRECTORY/output/shp/annual/' ||  substr(@inputsitespolygon, 7,3) || '_' || substr(@RastertoReclassify, 10, 4) || '.shp'
    ```


### Python Scripts
In order to run the python scripts:
* At the top of the processing toolbox, click the Python "Scripts" icon -> either `Open Existing Script` or `"Add Script to Toolbox"`. 
* Or Open the Python console (CTRL+ALT+P) and paste the script
### R Script
The R script (.rsx) is designed to merge the outcome of the `Reclassify and Get Zonal Histogram` model. To use it:
* R and QGIS must be linked (see the links at the end).
* The libraries loaded in the script (dplyr, janitor, magrittr) **MUST** be installed in R, if not already present.
* At the top of the processing toolbox, click the "R" icon ->  `Create New Script` -> paste it (**and save it**) -> run the script. 
* Once saved, the script can be found in the **processing toolbox** under `R/IraqEmergingSites/JoinZonalHistogramOutput`

***

## Useful Links for Using R in QGIS

[**QGIS Docs: Configuring External Application, R script**](https://docs.qgis.org/3.10/en/docs/user_manual/processing/3rdParty.html#r-scripts)

[**QGIS User Guide Appendix D: QGIS R Script Syntax**](https://docs.qgis.org/3.10/en/docs/user_manual/appendices/qgis_r_syntax.html#appendix-d-qgis-r-script-syntax)

[**QGIS Docs: Use R scripts in Processing**](https://docs.qgis.org/3.10/en/docs/training_manual/processing/r_intro.html)
