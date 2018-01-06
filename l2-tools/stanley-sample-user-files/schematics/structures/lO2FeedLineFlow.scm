global pirClasses
set pirClasses {lO2FeedLineFlow}
global pirClass
set pirClass(lO2FeedLineFlow) {nodeClassType structure class_variables {name_var {default {}} parentType {default <unspecified>} args {default {bleed sign}} argTypes {default {range signValues}} documentation {default {}} form {default {// the bleed range is in the positive flow range
if (bleed.lowerBound = aboveThreshold)
   sign = positive;
if (sign = zero)
   bleed.lowerBound = belowThreshold;}} valueList {default {}}}}

