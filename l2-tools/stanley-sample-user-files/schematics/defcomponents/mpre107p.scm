global pirNodes
set pirNodes {143 1 2 4 6 8 10 12}
global pirNode
set pirNode(143) {edgesFrom {{} {}} edgesTo {{}} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals {?name.pneumaticLineOut ?name.reportedPressure} input_terminals ?name.pneumaticLineIn nodeInstanceName ?name nodeState nominal nodeStateBgColor gray90 nodeClassName mpre107p numInputs 1 numOutputs 2 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {mpre107pSetPoints in} terminal_name ?name.pneumaticLineIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} outputs {out1 {type {mpre107pSetPoints out} terminal_name ?name.reportedPressure terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public} out2 {type {thresholdValues out} terminal_name ?name.pneumaticLineOut terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 105 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName mpre107p numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{reportedPressure = pneumaticLineIn;
pneumaticLineOut = pneumaticLineIn.rg21.lowerBound;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.nominal nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 200 nodeY 200 labelX 192 labelY 175 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = nominal)
  displayState = ok;
else
  displayState = unknown;}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 250 labelX 27 labelY 225 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {mpre107pSetPoints out} terminal_name ?name.pneumaticLineIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pneumaticLineIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 200 nodeY 130 labelX 162 labelY 105 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {mpre107pSetPoints in} terminal_name ?name.reportedPressure terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.reportedPressure nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 200 nodeY 290 labelX 159 labelY 265 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {thresholdValues in} terminal_name ?name.pneumaticLineOut terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pneumaticLineOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 270 nodeY 130 labelX 229 labelY 105 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 300 nodeY 200 labelX 292 labelY 175 window .master.canvas.?name.c.w16}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {mpre107p okMode displayState input output faultMode}
global pirClass
set pirClass(mpre107p) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} argTypes {default {}} documentation {default {}} input_terminals {default {{mpre107pSetPoints ?name.pneumaticLineIn {}}}} output_terminals {default {{mpre107pSetPoints ?name.reportedPressure {}} {thresholdValues ?name.pneumaticLineOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState {}}}} mode {default nominal} ok_modes {default nominal} fault_modes {default unknownFault} mode_transitions {default {}} background_model {default {pneumaticLineOut = pneumaticLineIn.rg21.lowerBound;}} background_documentation {default {}} initially {default {}} initial_mode {default nominal} recovery_modes {default {}}}}

set pirClass(okMode) {cfg_file okMode.cfg mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(displayState) {cfg_file displayState.cfg attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(input) {cfg_file input.cfg terminal_class input inputs {} outputs {} class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}} steady_state_power {default {}} steady_state_power_modes {default {}} mode_transitions {default {}} component_file {default {}} model_markers {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output.cfg terminal_class output inputs {} outputs {} class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}} steady_state_power {default {}} steady_state_power_modes {default {}} mode_transitions {default {}} component_file {default {}} model_markers {default {}}} nodeClassType terminal}

set pirClass(faultMode) {cfg_file faultMode.cfg mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {mpre107p}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {mpre107p}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
