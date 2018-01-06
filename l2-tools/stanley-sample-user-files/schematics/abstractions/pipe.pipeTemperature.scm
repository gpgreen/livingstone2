global pirClasses
set pirClasses {pipe.pipeTemperature}
global pirClass
set pirClass(pipe.pipeTemperature) {nodeClassType abstraction class_variables {name_var {default {}} parentType {default {}} args {default {this to}} argTypes {default {pipe temperatureValues}} documentation {default {MAJOR KLUGE! 
include temperature atttribute in pipe?? 
this.temperature.equal(to);}} form {default {pressure.sign = to.sign;
pressure.rel = to.rel;}} valueList {default {}}}}

