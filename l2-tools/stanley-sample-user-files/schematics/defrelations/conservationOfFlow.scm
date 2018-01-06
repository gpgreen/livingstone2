global pirClasses
set pirClasses {conservationOfFlow}
global pirClass
set pirClass(conservationOfFlow) {nodeClassType relation class_variables {name_var {default {}} parentType {default {}} args {default {this flowOut1 flowOut2}} argTypes {default {flowValues flowValues flowValues}} documentation {default {}} form {default {if (this.sign = positive)
   ((flowOut1.sign = positive) | (flowOut2.sign = positive));
if (this.sign = negative)
   ((flowOut1.sign = negative) | (flowOut2.sign = negative));
if (this.sign = zero) {
   iff (flowOut1.sign = zero) (flowOut2.sign = zero);
   iff (flowOut1.sign = positive) (flowOut2.sign = negative);
   iff (flowOut1.sign = negative) (flowOut2.sign = positive);}
if (this.rel = high)
   ((flowOut1.rel = high) | (flowOut2.rel = high));
if (this.rel = low)
   ((flowOut1.rel = low) | (flowOut2.rel = low));
if (this.rel = nominal) {
    iff (flowOut1.rel = nominal) (flowOut2.rel = nominal);
    if (! flowOut1.oppositeFlow(flowOut2)) {
         iff (flowOut1.rel = low) (flowOut2.rel = high);
         iff (flowOut1.rel = high) (flowOut2.rel = low);}
    if (flowOut1.oppositeFlow(flowOut2)) {
         iff (flowOut1.rel = high) (flowOut2.rel = high);
         iff (flowOut1.rel = low) (flowOut2.rel = low);}};}} valueList {default {}}}}

