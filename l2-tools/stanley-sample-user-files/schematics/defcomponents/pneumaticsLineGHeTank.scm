global pirNodes
set pirNodes {99 1 2 4 6 8}
global pirNode
set pirNode(99) {edgesFrom {{}} edgesTo {} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals ?name.pneumaticsLineOut input_terminals {} nodeInstanceName ?name nodeState nominal nodeStateBgColor gray90 nodeClassName pneumaticsLineGHeTank numInputs 0 numOutputs 1 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {} outputs {out1 {type {pneumaticsLine out} terminal_name ?name.pneumaticsLineOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 100 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName pneumaticsLineGHeTank numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{pneumaticsLineOut.pressure.rg21.upperBound = aboveThreshold;
pneumaticsLineOut.pressure.rg21.lowerBound = aboveThreshold;
pneumaticsLineOut.pressure.rg02.upperBound = aboveThreshold;
pneumaticsLineOut.pressure.rg02.lowerBound = aboveThreshold;
pneumaticsLineOut.temperature.tk02 = belowThreshold;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.nominal nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 280 nodeY 140 labelX 272 labelY 115 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pneumaticsLine in} terminal_name ?name.pneumaticsLineOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pneumaticsLineOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 280 nodeY 220 labelX 236 labelY 195 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = nominal)
  displayState = ok;
else
  displayState = unknown;}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 250 labelX 27 labelY 225 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 360 nodeY 140 labelX 352 labelY 115 window .master.canvas.?name.c.w12}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {pneumaticsLineGHeTank okMode output displayState faultMode}
global pirClass
set pirClass(pneumaticsLineGHeTank) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} argTypes {default {}} documentation {default {}} input_terminals {default {}} output_terminals {default {{pneumaticsLine ?name.pneumaticsLineOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState {}}}} mode {default nominal} ok_modes {default nominal} fault_modes {default unknownFault} mode_transitions {default {}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default nominal} recovery_modes {default {}}}}

set pirClass(okMode) {cfg_file okMode.cfg mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(output) {cfg_file output.cfg terminal_class output inputs {} outputs {} class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}} steady_state_power {default {}} steady_state_power_modes {default {}} mode_transitions {default {}} component_file {default {}} model_markers {default {}}} nodeClassType terminal}

set pirClass(displayState) {cfg_file displayState.cfg attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(faultMode) {cfg_file faultMode.cfg mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {pneumaticsLineGHeTank}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {pneumaticsLineGHeTank}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
