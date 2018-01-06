global pirClasses
set pirClasses {relativeValuesMoreThan}
global pirClass
set pirClass(relativeValuesMoreThan) {nodeClassType relation class_variables {name_var {default {}} parentType {default {}} args {default {this to}} argTypes {default {relativeValues relativeValues}} documentation {default {(and (not (r-equal ?from ?to ))
       (or (and (high ?from )
		(or (nominal ?to ) (low ?to )))
	   (and (nominal ?from )
		(low ?to ))
	   ))}} form {default {((this = high) & ((to = nominal) | (to =low))) |
      ((this = nominal) & (to = low));}} valueList {default {}}}}

