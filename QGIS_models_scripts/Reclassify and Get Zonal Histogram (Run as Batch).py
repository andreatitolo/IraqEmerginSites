from qgis.core import QgsProcessing
from qgis.core import QgsProcessingAlgorithm
from qgis.core import QgsProcessingMultiStepFeedback
from qgis.core import QgsProcessingParameterRasterLayer
from qgis.core import QgsProcessingParameterVectorLayer
from qgis.core import QgsProcessingParameterFeatureSink
from qgis.core import QgsExpression
import processing


class ReclassifyAndGetZonalHistogramRunAsBatch(QgsProcessingAlgorithm):

    def initAlgorithm(self, config=None):
        self.addParameter(QgsProcessingParameterRasterLayer('RastertoReclassify', 'Raster to Reclassify', defaultValue=None))
        self.addParameter(QgsProcessingParameterVectorLayer('inputsitespolygon', 'Input Sites Polygon', types=[QgsProcessing.TypeVectorPolygon], defaultValue=None))
        self.addParameter(QgsProcessingParameterFeatureSink('PolygonsZonalHistogram', 'Polygons Zonal Histogram', type=QgsProcessing.TypeVectorPolygon, createByDefault=True, defaultValue=None))

    def processAlgorithm(self, parameters, context, model_feedback):
        # Use a multi-step feedback, so that individual child algorithm progress reports are adjusted for the
        # overall progress through the model
        feedback = QgsProcessingMultiStepFeedback(2, model_feedback)
        results = {}
        outputs = {}

        # Reclassify with table
        alg_params = {
            'DATA_TYPE': 5,
            'INPUT_RASTER': parameters['RastertoReclassify'],
            'NODATA_FOR_MISSING': False,
            'NO_DATA': -9999,
            'RANGE_BOUNDARIES': 0,
            'RASTER_BAND': 1,
            'TABLE': [-1,0,0,0,1,1],
            'OUTPUT': QgsProcessing.TEMPORARY_OUTPUT
        }
        outputs['ReclassifyWithTable'] = processing.run('native:reclassifybytable', alg_params, context=context, feedback=feedback, is_child_algorithm=True)

        feedback.setCurrentStep(1)
        if feedback.isCanceled():
            return {}

        # Zonal Histogram
        alg_params = {
            'COLUMN_PREFIX': QgsExpression('substr( parameter(\'RastertoReclassify\'), 10, 8)').evaluate(),
            'INPUT_RASTER': outputs['ReclassifyWithTable']['OUTPUT'],
            'INPUT_VECTOR': parameters['inputsitespolygon'],
            'RASTER_BAND': 1,
            'OUTPUT': parameters['PolygonsZonalHistogram']
        }
        outputs['ZonalHistogram'] = processing.run('native:zonalhistogram', alg_params, context=context, feedback=feedback, is_child_algorithm=True)
        results['PolygonsZonalHistogram'] = outputs['ZonalHistogram']['OUTPUT']
        return results

    def name(self):
        return 'Reclassify and Get Zonal Histogram (Run as Batch)'

    def displayName(self):
        return 'Reclassify and Get Zonal Histogram (Run as Batch)'

    def group(self):
        return 'IraqEmergingSites'

    def groupId(self):
        return 'IraqEmergingSites'

    def shortHelpString(self):
        return """<html><body><h2>Descrizione dell'algoritmo</h2>
<p>RUN THIS MODEL AS BATCH PROCESS
This algorithm reclassify a series of rasters with a 2x3 table, and then count each unique reclassified value within different polygons in a shapefile, using the zonal histogram algorithm.

The model takes two input paramaters: a raster image, and a polygon shapefile. 

It outputs a shapefile with two columns appended, named with the year of the input raster filename.</p>
<h2>Parametri in ingresso</h2>
<h3>Raster to Reclassify</h3>
<p>The raster parameter, as used in this model, is an NDWI image with values between -1 to 1. 
When running this model as a batch process, a series of rasters can be selected.
The rasters will of course need to cover the area of the sites we want to analyse, otherwise the result will be a series of NULL values. </p>
<h3>Input Sites Polygon</h3>
<p>The Input Sites Polygon parameter, as used in this model, is a shapefile containing a series of polygons representing the extension of an archaeological site. 
I would suggest to use one shapefile at the time when running the model in batch process. 
However, more than one shapefile can be selected in the batch interface, just be careful to used it coupled with the correct rasters.</p>
<h3>Polygons Zonal Histogram</h3>
<p>The algorithm outputs a polygon shapefile with the columns of the original shp, and two more columns from the zonal histogram algorithm.

These two columns will contain the count of each unique pixels values (i.e. two categories) within each polygon features. 

The columns will be named using a subset of the original raster filename.
 The "_0" column will have the count of land pixels, while the "_1" column will have the count of water pixels.</p>
<h2>Risultati</h2>
<h3>Polygons Zonal Histogram</h3>
<p>The algorithm outputs a polygon shapefile with the columns of the original shp, and two more columns from the zonal histogram algorithm.

These two columns will contain the count of each unique pixels values (i.e. two categories) within each polygon features. 

The columns will be named using a subset of the original raster filename.
 The "_0" column will have the count of land pixels, while the "_1" column will have the count of water pixels.</p>
<br><p align="right">Autore dell'algoritmo: Dr. Andrea Titolo</p><p align="right">Autore della guida: Dr. Andrea Titolo</p><p align="right">Versione dell'algoritmo: 0.1</p></body></html>"""

    def helpUrl(self):
        return 'https://github.com/andreatitolo/IraqEmergingSites'

    def createInstance(self):
        return ReclassifyAndGetZonalHistogramRunAsBatch()
