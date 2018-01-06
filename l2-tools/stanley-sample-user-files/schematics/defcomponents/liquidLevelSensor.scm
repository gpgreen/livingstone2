global pirNodes
set pirNodes {76 1 2 4 6 8 10 12 14 16}
global pirNode
set pirNode(76) {edgesFrom {{}} edgesTo {{}} numArgsVars 0 argsValues {} attributes {?name.threshold ?name.llsMode ?name.displayState} port_terminals {} output_terminals ?name.levelReading input_terminals ?name.ambientLiquidLevel nodeInstanceName ?name nodeState dry nodeStateBgColor gray90 nodeClassName liquidLevelSensor numInputs 1 numOutputs 1 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {liquidLevelValues in} terminal_name ?name.ambientLiquidLevel terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} outputs {out1 {type {liquidLevelValues out} terminal_name ?name.levelReading terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 98 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName liquidLevelSensor numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label displayState}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = wet)
  this.displayState = wet;
else {
if (mode = dry)
  this.displayState = dry;
else 
  this.displayState = unknown;
};}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 60 labelX 27 labelY 35 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 610 nodeY 230 labelX 605 labelY 205 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {} edgesTo {} transitions {{startNode 6 stopNode 8 lineId 18 arrowId 19 defs {becomeDry {documentation {} when {this.ambientLiquidLevel.lessThan(this.threshold);} next dry cost 0}}} {startNode 8 stopNode 6}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{this.ambientLiquidLevel.equal(this.levelReading);}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.wet nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 360 nodeY 230 labelX 364 labelY 205 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {} edgesTo {} transitions {{startNode 6 stopNode 8} {startNode 8 stopNode 6 lineId -1 arrowId 20 defs {becomeWet {documentation {} when {this.ambientLiquidLevel.moreThan(this.threshold);} next wet cost 0}}}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{this.ambientLiquidLevel.equal(this.levelReading);}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.dry nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 530 nodeY 230 labelX 534 labelY 205 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {liquidLevelValues out} terminal_name ?name.ambientLiquidLevel terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ambientLiquidLevel nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 260 nodeY 120 labelX 213 labelY 95 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {liquidLevelValues out} terminal_name ?name.threshold terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.threshold nodeState {} nodeStateBgColor orange nodeClassName attribute fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 550 nodeY 120 labelX 536 labelY 95 window .master.canvas.?name.c.w16}

set pirNode(14) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {liquidLevelValues in} terminal_name ?name.levelReading terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.levelReading nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 380 nodeY 360 labelX 351 labelY 335 window .master.canvas.?name.c.w18}

set pirNode(16) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {openClosedValues out} terminal_name ?name.llsMode terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.llsMode nodeState {} nodeStateBgColor orange nodeClassName attribute fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 220 nodeY 230 labelX 212 labelY 205 window .master.canvas.?name.c.w20}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {liquidLevelSensor displayState faultMode okMode input attribute output}
global pirClass
set pirClass(liquidLevelSensor) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} documentation {default {}} input_terminals {default {{liquidLevelValues ?name.ambientLiquidLevel {}}}} output_terminals {default {{liquidLevelValues ?name.levelReading {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState displayState} {openClosedValues ?name.llsMode {}} {liquidLevelValues ?name.threshold {}}}} mode {default dry} ok_modes {default {wet dry}} fault_modes {default unknownFault} mode_transitions {default {{wet dry} {dry wet}}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default dry} recovery_modes {default {}} argTypes {default {}}}}

set pirClass(displayState) {cfg_file displayState attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(faultMode) {cfg_file faultMode mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(okMode) {cfg_file okMode mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(input) {cfg_file input terminal_class input class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(attribute) {cfg_file attribute attribute_class attribute class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(output) {cfg_file output terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {liquidLevelSensor}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {liquidLevelSensor}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
