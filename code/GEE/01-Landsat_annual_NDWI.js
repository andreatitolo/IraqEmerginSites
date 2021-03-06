// Last Update: 06/12/2020

// This code is also available directly in Google Earth Engine: 
https://code.earthengine.google.com/cf3d82e90d9f8f14b3afdbfbd71e451f?noload=true
// Click the link and then "run" once in GEE, in order to run the script

// This code will download monthly composites of Landsat images across a given time-frame
// Users will be able to edit parts of the script in order to adjust settings to their preference
// Specifically, Section 1.2 is designed to be the one to edit in order for the others to run  with the chosen settings
// Further edits can be done, if needed, at the end of section 4, in order to choose how many  images to display

// Table of Contents
// 0. Convert geometries to imports
// 1. SET-UP - Variables and Functions
    // 1.1 Editable Variables 
    // 1.2 Pre-Defined Variables
// 2. PROCESSING - Yearly Images
// 3. DISPLAY IMAGES
// 4. EXPORT IMAGES TO DRIVE

//                ------------------------------
//                     0. Import Geometries 
//                ------------------------------

// If copy-pasting from here, highlight all the code below and a prompt should show up to ask the user to convert the geometries into an imported record.

var geometry_mosul = 
    /* color: #d63000 */
    /* shown: false */
    /* displayProperties: [
      {
        "type": "rectangle"
      }
    ] */
    ee.Geometry.Polygon(
        [[[42.351434036097544, 37.007772518496346],
          [42.351434036097544, 36.55902574320424],
          [43.032586379847544, 36.55902574320424],
          [43.032586379847544, 37.007772518496346]]], null, false),
    geometry_hamrin = 
    /* color: #d63000 */
    /* shown: false */
    /* displayProperties: [
      {
        "type": "rectangle"
      }
    ] */
    ee.Geometry.Polygon(
        [[[44.8212486109187, 34.3825352662983],
          [44.8212486109187, 34.0338727840116],
          [45.20851667732495, 34.0338727840116],
          [45.20851667732495, 34.3825352662983]]], null, false),
    geomtry_haditha = 
    /* color: #ff0000 */
    /* shown: false */
    /* displayProperties: [
      {
        "type": "rectangle"
      }
    ] */
    ee.Geometry.Polygon(
        [[[41.575724127263584, 34.563088447300345],
          [41.575724127263584, 34.08675370370142],
          [42.501322271794834, 34.08675370370142],
          [42.501322271794834, 34.563088447300345]]], null, false);


//                ------------------------------
//                           1. SET-UP 
//                ------------------------------

//                ------------------------------------------
//                           1.1 Editable Variables 
//                ------------------------------------------

//                -----  Variables for selecting and processing images ----- 

// STUDY REGIONS to filter and clip the images, remove the "//" from the one you need to use and put the "//" to those that are not needed.

var study_region = geometry_mosul;
//var study_region = geometry_haditha;
//var study_region = geometry_hamrin;

// Define visualisation parameters for the NDWI images in Google Earth Engine
var ndwiParams = { min: -1, max: 1, palette: ['brown', 'white', 'blue'] };


// SELECT THE IMAGES TO USE
var BaseColl = ee.ImageCollection('LANDSAT/LT05/C01/T1_TOA'); // Landsat 5, available from 1984 to 2013. 
//var BaseColl = ee.ImageCollection('LANDSAT/LE07/C01/T1_TOA'); // Landsat 7, available from 1999 onward (SLC failure after 2003).
//var BaseColl = ee.ImageCollection('LANDSAT/LC08/C01/T1_TOA');  // Landsat 8, available from 2013 onwards.

// Define bands to use in the NDWI function with the "ndwi_bands" variable, REMEMBER to change it according to the images used
var L5bands = ['B2', 'B5'];
var L7bands = ['B2', 'B5'];
var L8bands = ['B3', 'B6'];

var ndwi_bands = L5bands;
//var ndwi_bands = L7bands;
//var ndwi_bands = L8bands;


//                -----  Variables for Names  ----- 

// With the following variables we are creating two strings as GEE server object
// This is optional, but we will use these later to create a consistent, machine-readable name for each image in the image collection

// Change the variables according to the study area and the selected images
var area = ee.String('mos_NDWI_');
//var area = ee.String("had_NDWI_");
//var area = ee.String("ham_NDWI_");

var sensor = ee.String("_L5");
//var sensor = ee.String("_L7");
//var sensor = ee.String("_L8");
//var sensor = ee.String("_S2");


//                -----  Variables for Exporting images ----- 


var exp_folder = 'Landsat 5'; // Here you can set the name of the new folder to be created in GDrive

var px_scale = 30;            // Set the pixel scale of the images to export                      




//                -----  Create Start and End Dates Variables ----- 

// Note: it seems that since around November 2020 days and months in the format  "01" throws an invalid number error when inside a loop/map involving dates.
// To avoid this, use e.g. 1984,1,1 instead of 1984,01,01 when defining start dates.

var start = ee.Date.fromYMD(1984,1,1); // Start date for Landsat 5
//var start = ee.Date.fromYMD(1999,1,1); // Start date for Landsat7
//var start = ee.Date.fromYMD(2013,1,1); // Start date for Landsat 8
//var start = ee.Date.fromYMD(2015,1,1);    // Start date for Sentinel 2

var years = ee.List.sequence(0, 14);  // Number of years for Landsat 5, according to the start date, this will return a list of year until 1998
//var years = ee.List.sequence(0, 13);  // Number of years for Landsat 7, according to the start date, this will return a list of year until 2013
//var years = ee.List.sequence(0, 6);   // Number of years for Landsat 8, according to the start date, this will return a list of year until 2019
//var years = ee.List.sequence(0, 4);   // Number of years for Sentinel2, according to the start date, this will return a list of year until 2019


// This function create start dates from the list of years created above. 
var startDates = years.map(function(d) {
  return start.advance(d, 'year');
});
print("Start dates", startDates); // Print and visualise the start dates



//                --------------------------------------------
//                           1.2 Pre-Defined Variables
//                --------------------------------------------

//                -----  Cloud Cover Percentage Filter ----- 

// Set the maximum percentage of cloud cover for image selection by tweaking this number
// Be aware that lower percentages might result in missing images when using it together with a short time-period filter (e.g. single months)

var cloud_filter = ee.Filter.lt("CLOUD_COVER", 0.1);



//                ----- Landsat Cloud Masking Function ----- 


// Cloud masking function for landsat images 
var maskLandsatclouds = function(image) {
  var qa = image.select('BQA');
  var cloudBitMask = ee.Number(2).pow(4).int();
  var mask = qa.bitwiseAnd(cloudBitMask).eq(0);
  return image.updateMask(mask)
      .select("B.*")
      .copyProperties(image, ["system:time_start"]);
};





//                ------------------------------
//                 2. PROCESSING - Yearly Images
//                ------------------------------


// Function to get image NDWI 
var getNDWI = function(img){
  var NDWI = img
    .normalizedDifference(ndwi_bands) 
    .rename("NDWI");
  return NDWI;
};

// This function was adapted from https://gis.stackexchange.com/questions/269313/mapping-over-list-of-dates-in-google-earth-engine

// Function to collect imagery by year
var yearmap = function(m){
  var start = ee.Date(m);                                 // get a starting date from the object that we are going to pass to the function
  var end = ee.Date(m).advance(1,'year');                 // here we get an end range for each step advancing by: 1 year
  var date_range = ee.DateRange(start,end);               // this creates n date ranges, according to how many Dates we set before
  var name = area.cat(start.format('YYYY')).cat(sensor);  // here we create a name property for each image made of the variables we set before and the starting date 
  var ImgYear = BaseColl                                  // select the dataset as ImageCollection
    .filterDate(date_range)                               // filter the collection for images within our date ranges
    .filterBounds(study_region)                           // filter the collection for images within our study region
    .filter(cloud_filter)                                 // filter for the percentage of cloud cover set before
    .map(maskLandsatclouds)                               // here we map the cloud function chosen before  
    .map(getNDWI)                                         // here we apply the NDWI function created before, this will add an NDWI band to each image in the collection
    .map(function(img){return img.clip(study_region)});   // return the images and clip them to our study region
  return(ImgYear.median().set({name: name}));             // apply the median reducer to mosaic the images and set the variable name as a property of the images.
};

// Here we map the function on the list of dates we created above, thus collecting as many images as our dates.
// the map function works like a for loop in this case
var list_of_images = startDates.map(yearmap); 
print('list_of_images', list_of_images);


// Turn the List created by the function to an ImageCollection GEE object.
var ImgColl = ee.ImageCollection(list_of_images);
print("Yearly NDWI", ImgColl);





//                ------------------------------
//                      3. DISPLAY IMAGES
//                ------------------------------

// For faster processing, use the function below. 
// This add the last image of the collection (the more recent)

// Map.addLayer(ImgColl,ndwiParams,"NDWI"); 


// However, we may want to check each image individually before downloading them.
// The functions below together with the batch export might freeze the browser page for some seconds, but it's normal.

// Select the number of images to display, set to 1 to display all of them (the value should not exceed the total generated images for each collection)
var images_to_not_display = 1; //this will remove n images from the collection and show all the others


var imageSetCollection = ImgColl.toList(ImgColl.size());

print(imageSetCollection);

var ImageList= ee.List.sequence(0,ee.Number(ImgColl.size().subtract(images_to_not_display))).getInfo();
var fun = function(img){

  var image = ee.Image(imageSetCollection.get(img));
  var names = ee.String(image.get('name')).getInfo();
  var label = img + '_' +names;
  
  Map.addLayer(image,ndwiParams, label);
};

ImageList.map(fun);
Map.centerObject(study_region, 9); // We center the map on our study area with a set zoom



//                ------------------------------
//                   4. EXPORT IMAGES TO DRIVE
//                ------------------------------

// Since there is no native way to export all the images in a Collection, we need to import an external module to do that
// The module was developed by Rodrigo E. Principe and is available at: https://github.com/fitoprincipe/geetools-code-editor
// This tool will create a folder in your Google Drive, where all the images in the collection will be exported. Refer to the link above for more details.

var batch = require('users/fitoprincipe/geetools:batch'); // Here we load the module
batch.Download.ImageCollection.toDrive(ImgColl, exp_folder, {
  name: '{name}',
  scale: px_scale,
  region: study_region,
  type: 'float'
});




