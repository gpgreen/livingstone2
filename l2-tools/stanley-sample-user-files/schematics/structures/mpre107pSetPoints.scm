global pirClasses
set pirClasses {mpre107pSetPoints}
global pirClass
set pirClass(mpre107pSetPoints) {nodeClassType structure class_variables {name_var {default {}} parentType {default <unspecified>} args {default {rg21 rg02}} argTypes {default {range range}} documentation {default {}} form {default {// we know at compile time which is bigger: 
// here it's rg21.upperBound >= rg02.lowerBound
// (although this may change)

if (rg21.upperBound = aboveThreshold)
   rg02.lowerBound = aboveThreshold;

if (rg02.lowerBound = belowThreshold)
   rg21.upperBound = belowThreshold;}} valueList {default {}}}}

