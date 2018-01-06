global pirNodes
set pirNodes {31 1 2 4 6 8 10 12 14 16 18}
global pirNode
set pirNode(31) {edgesFrom {{}} edgesTo {{} {}} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals ?name.pipeOut input_terminals {?name.pipeIn ?name.valveCmdIn} nodeInstanceName ?name nodeState closed nodeStateBgColor gray90 nodeClassName latchingSolenoidValve numInputs 2 numOutputs 1 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {openCloseLatchCommand in} terminal_name ?name.valveCmdIn terminal_label {} commandMonitorType {commanded noCommand} interfaceType public} in2 {type {pipe in} terminal_name ?name.pipeIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} outputs {out1 {type {pipe out} terminal_name ?name.pipeOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 105 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName latchingSolenoidValve numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label displayState}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = open)
  this.displayState = open;
else {
if (mode = closed)
  this.displayState = closed;
else {
if (mode = stuckOpen |
    mode = stuckClosed)
  this.displayState = failed;
else
  this.displayState = unknown;
}};}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 70 labelX 27 labelY 45 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 590 nodeY 240 labelX 585 labelY 215 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {} edgesTo {} transitions {{startNode 6 stopNode 8 lineId 20 arrowId 21 defs {closeValve {documentation {} when {this.valveCmdIn = close;} next closed cost 0}}} {startNode 8 stopNode 6}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{this.pipeIn.equal(this.pipeOut);}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.open nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 290 nodeY 180 labelX 291 labelY 155 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {} edgesTo {} transitions {{startNode 6 stopNode 8} {startNode 8 stopNode 6 lineId -1 arrowId 22 defs {openValve {documentation {} when {this.valveCmdIn = open;} next open cost 0}}}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{this.pipeIn.flow.sign = zero;
this.pipeOut.flow.sign = zero;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.closed nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 420 nodeY 180 labelX 415 labelY 155 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {openCloseLatchCommand out} terminal_name ?name.valveCmdIn terminal_label {} commandMonitorType {commanded noCommand} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.valveCmdIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 500 nodeY 90 labelX 477 labelY 65 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pipe out} terminal_name ?name.pipeIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pipeIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 360 nodeY 90 labelX 349 labelY 65 window .master.canvas.?name.c.w16}

set pirNode(14) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pipe in} terminal_name ?name.pipeOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pipeOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 360 nodeY 350 labelX 346 labelY 325 window .master.canvas.?name.c.w18}

set pirNode(16) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability likely model {{this.pipeIn.equal(this.pipeOut);}} nodeDescription {Stuck-open and stuck-closed are equally likely.} nodeClassType mode nodeInstanceName ?name.stuckOpen nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 290 nodeY 250 labelX 276 labelY 225 window .master.canvas.?name.c.w20}

set pirNode(18) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability likely model {{this.pipeIn.flow.sign = zero;
this.pipeIn.flow.sign = zero;}} nodeDescription {Stuck-open and stuck-closed are equally likely.} nodeClassType mode nodeInstanceName ?name.stuckClosed nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 420 nodeY 250 labelX 400 labelY 225 window .master.canvas.?name.c.w22}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {latchingSolenoidValve displayState faultMode okMode input output}
global pirClass
set pirClass(latchingSolenoidValve) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} documentation {default {A valve that stays in the previous state until explicitly commanded.}} input_terminals {default {{openCloseLatchCommand ?name.valveCmdIn {}} {pipe ?name.pipeIn {}}}} output_terminals {default {{pipe ?name.pipeOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState displayState}}} mode {default closed} ok_modes {default {open closed}} fault_modes {default {unknownFault stuckOpen stuckClosed}} mode_transitions {default {{open closed} {closed open}}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default closed} recovery_modes {default {}} argTypes {default {}}}}

set pirClass(displayState) {cfg_file displayState attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(faultMode) {cfg_file faultMode mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(okMode) {cfg_file okMode mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(input) {cfg_file input terminal_class input class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output.cfg terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {latchingSolenoidValve}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {latchingSolenoidValve}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
