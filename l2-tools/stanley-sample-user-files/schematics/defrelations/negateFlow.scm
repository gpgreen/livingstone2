global pirClasses
set pirClasses {negateFlow}
global pirClass
set pirClass(negateFlow) {nodeClassType relation class_variables {name_var {default {}} parentType {default {}} args {default {this to}} argTypes {default {flowValues flowValues}} documentation {default {}} form {default {if (this.sign = positive)
   to.sign = negative;
if (this.sign = negative)
   to.sign = positive;
if (this.sign = zero)
   to.sign = zero;
this.rel = to.rel;}} valueList {default {}}}}

