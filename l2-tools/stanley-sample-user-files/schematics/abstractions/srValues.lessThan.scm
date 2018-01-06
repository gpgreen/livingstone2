global pirClasses
set pirClasses {srValues.lessThan}
global pirClass
set pirClass(srValues.lessThan) {nodeClassType abstraction class_variables {name_var {default {}} parentType {default {}} args {default {this to}} argTypes {default {srValues srValues}} documentation {default {(and (not (sr-values-equal ?from ?to ))
       (or (sign-values-less-than (sign ?from ) (sign ?to ))
	   (and (s-equal (sign ?from ) (sign ?to ))
		(relative-values-less-than (rel ?from ) (rel ?to )))
	   ))}} form {default {(this.sign.signValuesLessThan(to.sign)) |
((this.sign = to.sign) & 
 this.rel.relativeValuesLessThan(to.rel));}} valueList {default {}}}}

