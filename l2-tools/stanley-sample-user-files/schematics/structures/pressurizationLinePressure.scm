global pirClasses
set pirClasses {pressurizationLinePressure}
global pirClass
set pirClass(pressurizationLinePressure) {nodeClassType structure class_variables {name_var {default {}} parentType {default <unspecified>} args {default {rg01 rg11}} argTypes {default {range range}} documentation {default {}} form {default {// we know at compile time which is bigger: 
// here it's rg11.upperBound <= rg01.lowerBound
// (although this may change)

if (rg11.upperBound = belowThreshold)
   rg01.lowerBound = belowThreshold;

if (rg01.lowerBound = aboveThreshold)
   rg11.upperBound = aboveThreshold;}} valueList {default {}}}}

