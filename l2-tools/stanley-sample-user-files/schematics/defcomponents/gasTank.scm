global pirNodes
set pirNodes {35 1 2 4 6 8 10 12 14 16 18 20}
global pirNode
set pirNode(35) {edgesFrom {{}} edgesTo {{}} numArgsVars 0 argsValues {} attributes {?name.internalPressure ?name.displayState} port_terminals {} output_terminals ?name.internalTemperature input_terminals ?name.pipeIn nodeInstanceName ?name nodeState empty nodeStateBgColor gray90 nodeClassName gasTank numInputs 1 numOutputs 1 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {pipe in} terminal_name ?name.pipeIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} outputs {out1 {type {temperatureValues out} terminal_name ?name.internalTemperature terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 100 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName gasTank numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label displayState}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = empty)
  this.displayState = empty;
else {
if (mode = full)
  this.displayState = full;
else {
if (mode = filling)
  this.displayState = filling;
else {
if (mode = emptying)
  this.displayState = emptying;
else {
if (mode = unknownFault)
  this.displayState = unknown;
}}}};}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 80 labelX 27 labelY 55 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 490 nodeY 290 labelX 485 labelY 265 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {temperatureValues in} terminal_name ?name.internalTemperature terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.internalTemperature nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 610 nodeY 380 labelX 560 labelY 355 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {} edgesTo {} transitions {{startNode 8 stopNode 18 lineId 22 arrowId 23 defs {startFilling {documentation {} when {((this.internalPressure.sign = zero) |
  ((this.internalPressure.sign = positive) &
   (this.internalPressure.rel = low)));
this.pipeIn.pressure.rel = nominal;
this.pipeIn.pressure.sign = positive;
this.pipeIn.flow.sign = positive;} next filling cost 0}}} {startNode 20 stopNode 8}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{this.internalPressure.sign = zero;
this.pipeOut.flow.sign = zero;
this.pipeIn.flow.sign = zero;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.empty nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 200 nodeY 290 labelX 198 labelY 265 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {} edgesTo {} transitions {{startNode 18 stopNode 10} {startNode 10 stopNode 20 lineId 24 arrowId 25 defs {startEmptying {documentation {} when {this.internalPressure.sign = positive;
this.internalPressure.rel = nominal;
this.pipeOut.flow.sign = positive;} next emptying cost 0}}}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{this.internalPressure.sign = positive;
this.internalTemperature.sign = positive;
(((this.internalPressure.rel = nominal) &
  (this.internalTemperature.rel = nominal)) |
 ((this.internalPressure.rel = high) &
  (this.internalTemperature.rel = high)));}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.full nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 400 nodeY 290 labelX 401 labelY 265 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pressureValues out} terminal_name ?name.internalPressure terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.internalPressure nodeState {} nodeStateBgColor orange nodeClassName attribute fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 610 nodeY 220 labelX 575 labelY 195 window .master.canvas.?name.c.w16}

set pirNode(14) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pipe out} terminal_name ?name.pipeIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pipeIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 310 nodeY 160 labelX 299 labelY 135 window .master.canvas.?name.c.w18}

set pirNode(16) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pipe in} terminal_name ?name.pipeOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType private}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pipeOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 0 nodeX 300 nodeY 420 labelX 286 labelY 395 window .master.canvas.?name.c.w20}

set pirNode(18) {edgesFrom {} edgesTo {} transitions {{startNode 8 stopNode 18} {startNode 18 stopNode 10 lineId 26 arrowId 27 defs {fillingUp {documentation {} when {this.pipeIn.pressure.sign = positive;
this.pipeIn.pressure.rel = nominal;
this.pipeIn.flow.sign = positive;
this.internalPressure.sign = positive;
this.internalPressure.rel = nominal;} next full cost 0}}}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{this.pipeIn.pressure.sign = positive;
this.pipeIn.pressure.moreThan(this.internalPressure);
this.pipeIn.flow.sign = positive;
this.pipeOut.flow.sign = zero;
this.pipeIn = this.pipeOut;
((this.internalPressure.sign = zero) |
 ((this.internalPressure.sign = positive) &
  (this.internalPressure.rel = low)));}} nodeDescription {The tank is filling when the inlet pressure is greater than the internal 
pressure, and there is a positive flow into the tank and no outflow.} nodeClassType mode nodeInstanceName ?name.filling nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 300 nodeY 240 labelX 292 labelY 215 window .master.canvas.?name.c.w22}

set pirNode(20) {edgesFrom {} edgesTo {} transitions {{startNode 10 stopNode 20} {startNode 20 stopNode 8 lineId 28 arrowId 29 defs {emptiedOut {documentation {} when {this.internalPressure.sign = zero;
this.pipeOut.flow.sign = positive;} next empty cost 0}}}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{this.internalPressure.sign = positive;
((this.internalPressure.rel = nominal) |
 (this.internalPressure.rel = low));
this.pipeIn.flow.sign = zero;
this.pipeOut.flow.sign = positive;
this.pipeIn = this.pipeOut;
this.internalPressure = this.pipeOut.pressure;}} nodeDescription {The tank is emptying when there is no flow at the inlet, and positive flow at 
the outlet.} nodeClassType mode nodeInstanceName ?name.emptying nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 300 nodeY 330 labelX 289 labelY 305 window .master.canvas.?name.c.w24}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {gasTank displayState faultMode output okMode attribute input}
global pirClass
set pirClass(gasTank) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} documentation {default {A generic tank or accumulator for holding gaseous expendables.}} input_terminals {default {{pipe ?name.pipeIn {}}}} output_terminals {default {{temperatureValues ?name.internalTemperature {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState displayState} {pressureValues ?name.internalPressure {}}}} mode {default empty} ok_modes {default {empty full filling emptying}} fault_modes {default unknownFault} mode_transitions {default {{empty filling} {full emptying} {filling full} {emptying empty}}} background_model {default {}} background_documentation {default {}} initially {default {this.pipeIn.pressure.sign = zero;
// for testing
this.pipeIn.pressure.rel = low;}} initial_mode {default empty} recovery_modes {default {}} argTypes {default {}}}}

set pirClass(displayState) {cfg_file displayState attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(faultMode) {cfg_file faultMode mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(output) {cfg_file output terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(okMode) {cfg_file okMode mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(attribute) {cfg_file attribute.cfg attribute_class attribute class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(input) {cfg_file input.cfg terminal_class input class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {gasTank}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {gasTank}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
