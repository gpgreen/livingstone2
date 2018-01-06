global pirClasses
set pirClasses {srValues.moreThan}
global pirClass
set pirClass(srValues.moreThan) {nodeClassType abstraction class_variables {name_var {default {}} parentType {default {}} args {default {this to}} argTypes {default {srValues srValues}} documentation {default {(and (not (sr-values-equal ?from ?to ))
       (or (sign-values-more-than (sign ?from ) (sign ?to ))
	   (and (s-equal (sign ?from ) (sign ?to ))
		(relative-values-more-than (rel ?from ) (rel ?to )))
	   ))}} form {default {this.sign.signValuesMoreThan(to.sign) |
((this.sign = to.sign) &
 this.rel.relativeValuesMoreThan(to.rel));}} valueList {default {}}}}

