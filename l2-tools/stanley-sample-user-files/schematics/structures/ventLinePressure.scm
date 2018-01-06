global pirClasses
set pirClasses {ventLinePressure}
global pirClass
set pirClass(ventLinePressure) {nodeClassType structure class_variables {name_var {default {}} parentType {default <unspecified>} args {default {pr02Crack pressurizationRate boiloffRate bleedRate ventingRate}} argTypes {default {thresholdValues range range range range}} documentation {default {}} form {default {// the pressurizationRate range is above the boiloffRate range is above
// the bleedRate range is above the ventingRate range.

if (pressurizationRate.lowerBound = aboveThreshold)
   boiloffRate.upperBound = aboveThreshold;
if (boiloffRate.upperBound = belowThreshold)
   pressurizationRate.lowerBound = belowThreshold;

if (boiloffRate.lowerBound = aboveThreshold)
   bleedRate.upperBound = aboveThreshold;
if (bleedRate.upperBound = belowThreshold)
   boiloffRate.lowerBound = belowThreshold;

if (bleedRate.lowerBound = aboveThreshold)
   ventingRate.upperBound = aboveThreshold;
if (ventingRate.upperBound = belowThreshold)
   bleedRate.lowerBound = belowThreshold;}} valueList {default {}}}}

