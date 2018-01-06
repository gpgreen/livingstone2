global pirClasses
set pirClasses {relativeValuesLessThan}
global pirClass
set pirClass(relativeValuesLessThan) {nodeClassType relation class_variables {name_var {default {}} parentType {default {}} args {default {this to}} argTypes {default {relativeValues relativeValues}} documentation {default {(and (not (r-equal ?from ?to ))
       (or (and (low ?from )
		(or (nominal ?to ) (high ?to )))
	   (and (nominal ?from )
		(high ?to ))
	   ))}} form {default {((this = low) & ((to = nominal) | (to = high))) |
 ((this = nominal) & (to = high));}} valueList {default {}}}}

