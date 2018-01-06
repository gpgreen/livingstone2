global pirNodes
set pirNodes {111 1 2 4 6 8}
global pirNode
set pirNode(111) {edgesFrom {{}} edgesTo {} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals ?name.pipeOut input_terminals {} nodeInstanceName ?name nodeState nominal nodeStateBgColor gray90 nodeClassName ambientSource numInputs 0 numOutputs 1 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {} outputs {out1 {type {pipe out} terminal_name ?name.pipeOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 0 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX -1 labelY -1 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P3 nodeState parent-link nodeStateBgColor gray90 nodeClassName ambientSource numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w4 nodeHasIconP 0}

set pirNode(2) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{pipeOut.pressure.rel = nominal;
pipeOut.pressure.sign = zero;
pipeOut.flow.rel = nominal;
pipeOut.flow.sign = zero;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.nominal nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 250 nodeY 110 labelX 242 labelY 85 window .master.canvas.?name.c.w5}

set pirNode(4) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label displayState}} numOutputs 1 inputs {} numInputs 0 facts {{if ( mode = nominal )
  displayState = ok;
else
  displayState = unknown;}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 250 labelX 27 labelY 225 window .master.canvas.?name.c.w7}

set pirNode(6) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pipe in} terminal_name ?name.pipeOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {A source of ambient pressure} nodeClassType terminal nodeInstanceName ?name.pipeOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 250 nodeY 270 labelX 236 labelY 245 window .master.canvas.?name.c.w9}

set pirNode(8) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 360 nodeY 110 labelX 352 labelY 85 window .master.canvas.?name.c.w11}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {ambientSource okMode displayState output faultMode}
global pirClass
set pirClass(ambientSource) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default ?context} documentation {default {Low-pressure source representing the ambient environment.}} input_terminals {default {}} output_terminals {default {{pipe ?name.pipeOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState displayState}}} mode {default nominal} ok_modes {default nominal} fault_modes {default unknownFault} mode_transitions {default {}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default nominal} recovery_modes {default {}} argTypes {default contextValue}}}

set pirClass(okMode) {cfg_file okMode.cfg mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(displayState) {cfg_file displayState.cfg attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(output) {cfg_file output.cfg terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(faultMode) {cfg_file faultMode.cfg mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {ambientSource}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {ambientSource}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {?context}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {contextValue}
