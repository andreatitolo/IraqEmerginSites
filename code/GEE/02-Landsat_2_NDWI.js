
// This code is also available directly in Google Earth Engine: 

// Click the link and then "run" once in GEE, in order to run the script
https://code.earthengine.google.com/7f310c97576e2f9971bd12f3090a0270?noload=true
// This code will download a single Landsat 2 image for the year 1975 (before the construction of the Hamrin Dam)
// The code can be edited by changing values directly into the functions below

//                ------------------------------
//                       Import Geometries 
//                ------------------------------

// If copy-pasting from here, highlight all the code below and a prompt should show up to ask the user to convert the geometries into an imported record.

var geometry_hamrin = 
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
          [45.20851667732495, 34.3825352662983]]], null, false);


          
//                --------------------------------------------
//                           Variables and Functions
//                --------------------------------------------

// Define visualisation parameters for the NDWI images in Google Earth Engine
var ndwiParams = { min: -1, max: 1, palette: ['brown', 'white', 'blue'] };

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
//                     PROCESSING - Landsat 2
//                ------------------------------

//                ------------- Landsat 2 ------------- 
// Be aware that Landsat 2 scenes are provided in DN values, so they need to be converted to TOA reflectance for this analysis
// No need to change geometry here, we are interested only in the Hamrin area
var L2_DN = ee.ImageCollection("LANDSAT/LM02/C01/T2")
  .filter(ee.Filter.date('1975-01-01', '1975-12-30')) // you can change date here
  .filter(ee.Filter.lt("CLOUD_COVER", 0.1))
  .filterBounds(geometry_hamrin)
  .map(maskLandsatclouds)
  .sort('CLOUD_COVER');


// Get the first image (least cloudy), there is no need to mosaic in this case since we
var L2_first = ee.Image(L2_DN.first());
// Convert the DN data to top-of-atmosphere reflectance and clip to your geometry
var L2 = ee.Algorithms.Landsat.TOA(L2_first).clip(geometry_hamrin);
print('L2', L2);

var green = L2.select('B4');
var swir = L2.select('B7');
var ndwi_L2 = green.subtract(swir).divide(green.add(swir)).rename('NDWI');

Map.addLayer(ndwi_L2, ndwiParams,'NDWI_L2_image'); 
Map.centerObject(geometry_hamrin, 10); // We center the map on our study area with a set zoom


Export.image.toDrive({
  image: ndwi_L2,
  description: 'ham_NDWI_1975_L2',   
  scale: 80,
  maxPixels: 1e13,
  crs: 'EPSG:4326',
  region: geometry_hamrin
});
