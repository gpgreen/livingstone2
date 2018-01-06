global pirClasses
set pirClasses {pneumaticsLinePressure}
global pirClass
set pirClass(pneumaticsLinePressure) {nodeClassType structure class_variables {name_var {default {}} parentType {default <unspecified>} args {default {rg02 rg21}} argTypes {default {range range}} documentation {default {}} form {default {// we know at compile time which is bigger: 
// here it's rg21.upperBound <= rg02.lowerBound
// (although this may change)

if (rg21.upperBound = belowThreshold)
   rg02.lowerBound = belowThreshold;

if (rg02.lowerBound = aboveThreshold)
   rg21.upperBound = aboveThreshold;}} valueList {default {}}}}

