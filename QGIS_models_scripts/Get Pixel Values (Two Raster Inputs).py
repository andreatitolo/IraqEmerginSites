from qgis.core import QgsProcessing
from qgis.core import QgsProcessingAlgorithm
from qgis.core import QgsProcessingMultiStepFeedback
from qgis.core import QgsProcessingParameterMultipleLayers
from qgis.core import QgsProcessingParameterVectorLayer
from qgis.core import QgsProcessingParameterVectorDestination
import processing


class GetPixelValuesTwoRasterInputs(QgsProcessingAlgorithm):

    def initAlgorithm(self, config=None):
        self.addParameter(QgsProcessingParameterMultipleLayers('inputndwirasters2', 'Input Rasters (years)', layerType=QgsProcessing.TypeRaster, defaultValue=None))
        self.addParameter(QgsProcessingParameterMultipleLayers('inputndwirasters2018', 'Input Rasters (2018)', optional=True, layerType=QgsProcessing.TypeRaster, defaultValue=None))
        self.addParameter(QgsProcessingParameterVectorLayer('inputsitespoints', 'Input Sites Points', types=[QgsProcessing.TypeVectorPoint], defaultValue=None))
        self.addParameter(QgsProcessingParameterVectorDestination('Sitespixelvalues', 'SitesPixelValues', type=QgsProcessing.TypeVectorAnyGeometry, createByDefault=True, defaultValue=None))
        self.addParameter(QgsProcessingParameterVectorDestination('Sitespixelvalues2018', 'SitesPixelValues2018', type=QgsProcessing.TypeVectorAnyGeometry, createByDefault=True, defaultValue=None))

    def processAlgorithm(self, parameters, context, model_feedback):
        # Use a multi-step feedback, so that individual child algorithm progress reports are adjusted for the
        # overall progress through the model
        feedback = QgsProcessingMultiStepFeedback(2, model_feedback)
        results = {}
        outputs = {}

        # Add raster values to points
        alg_params = {
            'GRIDS': parameters['inputndwirasters2018'],
            'RESAMPLING': 0,
            'SHAPES': parameters['inputsitespoints'],
            'RESULT': parameters['Sitespixelvalues2018']
        }
        outputs['AddRasterValuesToPoints'] = processing.run('saga:addrastervaluestopoints', alg_params, context=context, feedback=feedback, is_child_algorithm=True)
        results['Sitespixelvalues2018'] = outputs['AddRasterValuesToPoints']['RESULT']

        feedback.setCurrentStep(1)
        if feedback.isCanceled():
            return {}

        # Add raster values to points
        alg_params = {
            'GRIDS': parameters['inputndwirasters2'],
            'RESAMPLING': 0,
            'SHAPES': parameters['inputsitespoints'],
            'RESULT': parameters['Sitespixelvalues']
        }
        outputs['AddRasterValuesToPoints'] = processing.run('saga:addrastervaluestopoints', alg_params, context=context, feedback=feedback, is_child_algorithm=True)
        results['Sitespixelvalues'] = outputs['AddRasterValuesToPoints']['RESULT']
        return results

    def name(self):
        return 'Get Pixel Values (Two Raster Inputs)'

    def displayName(self):
        return 'Get Pixel Values (Two Raster Inputs)'

    def group(self):
        return 'IraqEmergingSites'

    def groupId(self):
        return 'IraqEmergingSites'

    def shortHelpString(self):
        return """<html><body><h2>Descrizione dell'algoritmo</h2>
<p>This algorithm extract pixel values from two sets of raster at each point location defined by a point shapefile. The outputs are two point shapefiles with new columns (as many as any input raster) containing pixel value at that location.

The algorithm uses SAGA's "Add Raster values to point" algorithm.</p>
<h2>Parametri in ingresso</h2>
<h3>Input Rasters (years)</h3>
<p>A series of raster, these can be either layers open in QGIS, or files inside a folder. 
In this model, these rasters are supposed to be those relative to the annual analysis.</p>
<h3>Input Rasters (2018)</h3>
<p>A series of raster, these can be either layers open in QGIS, or files inside a folder. 
In this model, these rasters are supposed to be those relative to the 2018 monthly analysis.

This parameter is optional, if not supplied, the model will output only the first shapefile related to "InputRasters(years)"</p>
<h3>Input Sites Points</h3>
<p>A vector containing points. Of course, these points need to be inside the input rasters coverage. In this model the points represent archaeological sites location.</p>
<h3>SitesPixelValues</h3>
<p>A vector with the original fields of the input vector and new columns resulted from the "Add Raster Values to Points" algorithm. This output will store the pixel values from the annual rasters.</p>
<h3>SitesPixelValues2018</h3>
<p>A vector with the original fields of the input vector and new columns resulted from the "Add Raster Values to Points" algorithm. This output will store the pixel values from the 2018 monthly rasters.</p>
<h2>Risultati</h2>
<h3>SitesPixelValues</h3>
<p>A vector with the original fields of the input vector and new columns resulted from the "Add Raster Values to Points" algorithm. This output will store the pixel values from the annual rasters.</p>
<h3>SitesPixelValues2018</h3>
<p>A vector with the original fields of the input vector and new columns resulted from the "Add Raster Values to Points" algorithm. This output will store the pixel values from the 2018 monthly rasters.</p>
<br><p align="right">Autore dell'algoritmo: Dr. Andrea Titolo</p><p align="right">Autore della guida: Dr. Andrea Titolo</p><p align="right">Versione dell'algoritmo: 0.1</p></body></html>"""

    def createInstance(self):
        return GetPixelValuesTwoRasterInputs()
