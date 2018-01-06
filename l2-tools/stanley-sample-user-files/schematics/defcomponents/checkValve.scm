global pirNodes
set pirNodes {5 1 2 4 6 8 10 12}
global pirNode
set pirNode(5) {edgesFrom {{}} edgesTo {{}} numArgsVars 0 argsValues {} attributes {?name.cvMode ?name.displayState} port_terminals {} output_terminals ?name.pipeOut input_terminals ?name.pipeIn nodeInstanceName ?name nodeState nominal nodeStateBgColor gray90 nodeClassName checkValve numInputs 1 numOutputs 1 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {pipe in} terminal_name ?name.pipeIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} outputs {out1 {type {pipe out} terminal_name ?name.pipeOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 100 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName checkValve numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label displayState}} numOutputs 1 inputs {} numInputs 0 facts {{if (this.mode = unknownFault)
  this.displayState = unknown;

if (this.cvMode = open)
  this.displayState = open;

if (this.cvMode = closed)
  this.displayState = closed;}} nodeDescription {Show whether valve is open (nominal) or closed (backflow).} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 50 labelX 27 labelY 25 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 580 nodeY 280 labelX 575 labelY 255 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{if ((! pipeIn.pressure.moreThan(?crackPressure)) |
    (pipeIn.flow.sign = zero) | (pipeIn.flow.sign = negative))
  cvMode = closed;
else
  cvMode = open;
if (cvMode = closed) {
  pipeIn.flow.sign = zero;
  pipeOut.flow.sign = zero;
}
if (cvMode = open)
  pipeIn = pipeOut;}} nodeDescription {The check valve is open when flow is in the forward direction, and closed
otherwise. 

Note: the pressure difference between pipe-in and pipe-out must exceed the crack-pressure for the check-valve to open.} nodeClassType mode nodeInstanceName ?name.nominal nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 350 nodeY 280 labelX 342 labelY 255 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {openClosedValues out} terminal_name ?name.cvMode terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.cvMode nodeState {} nodeStateBgColor orange nodeClassName attribute fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 200 nodeY 290 labelX 195 labelY 265 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pipe out} terminal_name ?name.pipeIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pipeIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 480 nodeY 130 labelX 469 labelY 105 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pipe in} terminal_name ?name.pipeOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pipeOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 480 nodeY 390 labelX 466 labelY 365 window .master.canvas.?name.c.w16}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {checkValve displayState faultMode okMode attribute input output}
global pirClass
set pirClass(checkValve) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {?context ?crackPressure}} documentation {default {}} input_terminals {default {{pipe ?name.pipeIn {}}}} output_terminals {default {{pipe ?name.pipeOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState displayState} {openClosedValues ?name.cvMode {}}}} mode {default nominal} ok_modes {default nominal} fault_modes {default unknownFault} mode_transitions {default {}} background_model {default {}} background_documentation {default {}} initially {default {pipeIn.pressure.sign = zero;
pipeIn.flow.sign = zero;}} initial_mode {default nominal} recovery_modes {default {}} argTypes {default {contextValue pressureValues}}}}

set pirClass(displayState) {cfg_file displayState attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(faultMode) {cfg_file faultMode mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(okMode) {cfg_file okMode mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(attribute) {cfg_file attribute attribute_class attribute class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(input) {cfg_file input.cfg terminal_class input class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output.cfg terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {checkValve}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {checkValve}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {?context ?crackPressure}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {contextValue pressureValues}
