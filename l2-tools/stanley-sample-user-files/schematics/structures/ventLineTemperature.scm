global pirClasses
set pirClasses {ventLineTemperature}
global pirClass
set pirClass(ventLineTemperature) {nodeClassType structure class_variables {name_var {default {}} parentType {default <unspecified>} args {default {ambient tankMixture}} argTypes {default {range range}} documentation {default {}} form {default {// the ambient temperature range is well above any upperBound
// on the temperature of the tank mixture in the ventLine.
if (tankMixture.upperBound = belowThreshold)
   ambient.lowerBound = belowThreshold;
if (ambient.lowerBound = aboveThreshold)
   tankMixture.upperBound = aboveThreshold;}} valueList {default {}}}}

