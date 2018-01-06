global pirClasses
set pirClasses {pressurizationLine}
global pirClass
set pirClass(pressurizationLine) {nodeClassType structure class_variables {name_var {default {}} parentType {default <unspecified>} args {default {pressure temperature contents}} argTypes {default {pressurizationLinePressure pressurizationLineTemperature pressurizationLineContents}} documentation {default {}} form {default {// assume that temperature at a location in the line is a function
// of mixture only, so that upper and lower bounds are conservatively
// chosen to reflect all possible pressures.  (we may need to come
// up with tighter bounds that are a function of pressure in the
// future).

if (contents = gHe)
   temperature.gHe.upperBound = belowThreshold &  
   temperature.gHe.lowerBound = aboveThreshold;

if (contents = tankMixture)
   temperature.tankMixture.upperBound = belowThreshold &  
   temperature.tankMixture.lowerBound = aboveThreshold;}} valueList {default {}}}}

