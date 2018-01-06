global pirNodes
set pirNodes {93 1 2 4 6 8 10 12 14}
global pirNode
set pirNode(93) {edgesFrom {{}} edgesTo {{} {}} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals ?name.flowOut input_terminals {?name.valveCmdIn ?name.flowIn} nodeInstanceName ?name nodeState open nodeStateBgColor gray90 nodeClassName genericValve numInputs 2 numOutputs 1 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {srValues in} terminal_name ?name.flowIn terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public} in2 {type {openCloseCommand in} terminal_name ?name.valveCmdIn terminal_label {} commandMonitorType {commanded noCommand} interfaceType public}} outputs {out1 {type {srValues out} terminal_name ?name.flowOut terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 0 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX -1 labelY -1 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P3 nodeState parent-link nodeStateBgColor gray90 nodeClassName genericValve numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w4 nodeHasIconP 0}

set pirNode(2) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 570 nodeY 270 labelX 565 labelY 245 window .master.canvas.?name.c.w5}

set pirNode(4) {edgesFrom {} edgesTo {} transitions {{startNode 4 stopNode 6 lineId 16 arrowId 17 defs {closeValve {documentation {} when {this.valveCmdIn = closed;} next closed cost 0}}} {startNode 6 stopNode 4}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{this.flowOut.equal(this.flowIn);}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.open nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 300 nodeY 270 labelX 301 labelY 245 window .master.canvas.?name.c.w7}

set pirNode(6) {edgesFrom {} edgesTo {} transitions {{startNode 4 stopNode 6} {startNode 6 stopNode 4 lineId -1 arrowId 18 defs {openValve {documentation {} when {this.valveCmdIn = open;} next open cost 0}}}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{this.flowOut = zero;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.closed nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 450 nodeY 270 labelX 445 labelY 245 window .master.canvas.?name.c.w9}

set pirNode(8) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {srValues out} terminal_name ?name.flowIn terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.flowIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 420 nodeY 160 labelX 409 labelY 135 window .master.canvas.?name.c.w11}

set pirNode(10) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {srValues in} terminal_name ?name.flowOut terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.flowOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 420 nodeY 410 labelX 406 labelY 385 window .master.canvas.?name.c.w13}

set pirNode(12) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label displayState}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = open)
  displayState = open;
else {
  if (mode = closed)
    displayState = closed;
  else
    displayState = unknown;
};}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 80 labelX 27 labelY 55 window .master.canvas.?name.c.w15}

set pirNode(14) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {openCloseCommand out} terminal_name ?name.valveCmdIn terminal_label {} commandMonitorType {commanded noCommand} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.valveCmdIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 290 nodeY 160 labelX 267 labelY 135 window .master.canvas.?name.c.w17}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {genericValve faultMode okMode input output displayState}
global pirClass
set pirClass(genericValve) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} documentation {default {}} input_terminals {default {{srValues ?name.flowIn {}} {openCloseCommand ?name.valveCmdIn {}}}} output_terminals {default {{srValues ?name.flowOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState displayState}}} mode {default open} ok_modes {default {open closed}} fault_modes {default unknownFault} mode_transitions {default {{open closed} {closed open}}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default open} recovery_modes {default {}} argTypes {default {}}}}

set pirClass(faultMode) {cfg_file faultMode mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(okMode) {cfg_file okMode mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(input) {cfg_file input terminal_class input class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(displayState) {cfg_file displayState attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {genericValve}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {genericValve}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
