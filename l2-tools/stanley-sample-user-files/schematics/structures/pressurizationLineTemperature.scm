global pirClasses
set pirClasses {pressurizationLineTemperature}
global pirClass
set pirClass(pressurizationLineTemperature) {nodeClassType structure class_variables {name_var {default {}} parentType {default <unspecified>} args {default {gHe tankMixture}} argTypes {default {range range}} documentation {default {}} form {default {// the tank mixture is colder than gHe
if (tankMixture.upperBound = belowThreshold)
   gHe.lowerBound = belowThreshold;

if (gHe.lowerBound = aboveThreshold)
   tankMixture.upperBound = aboveThreshold;}} valueList {default {}}}}

