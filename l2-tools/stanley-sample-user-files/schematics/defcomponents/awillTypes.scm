global pirNodes
set pirNodes {52 1 2 4 6 8 10 12 14 16 18}
global pirNode
set pirNode(52) {edgesFrom {{} {} {}} edgesTo {{} {} {}} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals {?name.outPipe ?name.outSrValues ?name.outSignValues} input_terminals {?name.inPipe ?name.inSrValues ?name.inSignValues} nodeInstanceName ?name nodeState ok nodeStateBgColor gray90 nodeClassName awillTypes numInputs 3 numOutputs 3 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {signValues in} terminal_name ?name.inSignValues terminal_label {} commandMonitorType {monitored unknown} interfaceType public} in2 {type {srValues in} terminal_name ?name.inSrValues terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public} in3 {type {pipe in} terminal_name ?name.inPipe terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} outputs {out1 {type {signValues out} terminal_name ?name.outSignValues terminal_label {} commandMonitorType {monitored unknown} interfaceType public} out2 {type {srValues out} terminal_name ?name.outSrValues terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public} out3 {type {pipe out} terminal_name ?name.outPipe terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 0 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX -1 labelY -1 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P3 nodeState parent-link nodeStateBgColor gray90 nodeClassName awillTypes numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w4 nodeHasIconP 0}

set pirNode(2) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {signValues out} terminal_name ?name.inSignValues terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.inSignValues nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 240 nodeY 130 labelX 211 labelY 105 window .master.canvas.?name.c.w5}

set pirNode(4) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {signValues in} terminal_name ?name.outSignValues terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.outSignValues nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 240 nodeY 360 labelX 208 labelY 335 window .master.canvas.?name.c.w7}

set pirNode(6) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {srValues out} terminal_name ?name.inSrValues terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.inSrValues nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 330 nodeY 130 labelX 307 labelY 105 window .master.canvas.?name.c.w9}

set pirNode(8) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {srValues in} terminal_name ?name.outSrValues terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.outSrValues nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 320 nodeY 360 labelX 294 labelY 335 window .master.canvas.?name.c.w11}

set pirNode(10) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pipe out} terminal_name ?name.inPipe terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.inPipe nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 410 nodeY 130 labelX 399 labelY 105 window .master.canvas.?name.c.w13}

set pirNode(12) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pipe in} terminal_name ?name.outPipe terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.outPipe nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 400 nodeY 360 labelX 386 labelY 335 window .master.canvas.?name.c.w15}

set pirNode(14) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{inSignValues = outSignValues;
inSrValues.sign = outSrValues.sign;
inSrValues.rel = outSrValues.rel;
inPipe.pressure.sign = outPipe.pressure.sign;
inPipe.pressure.rel = outPipe.pressure.rel;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.ok nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 320 nodeY 240 labelX 327 labelY 215 window .master.canvas.?name.c.w17}

set pirNode(16) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label {} commandMonitorType ?name.displayState interfaceType {}}} numOutputs 1 inputs {} numInputs 0 facts {{displayState = noData;}} nodeDescription {default display state -- will never change} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 250 labelX 27 labelY 225 window .master.canvas.?name.c.w19}

set pirNode(18) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 440 nodeY 240 labelX 429 labelY 215 window .master.canvas.?name.c.w21}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {awillTypes input output okMode displayState faultMode}
global pirClass
set pirClass(awillTypes) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} argTypes {default {}} documentation {default {}} input_terminals {default {{signValues ?name.inSignValues {}} {srValues ?name.inSrValues {}} {pipe ?name.inPipe {}}}} output_terminals {default {{signValues ?name.outSignValues {}} {srValues ?name.outSrValues {}} {pipe ?name.outPipe {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState {}}}} mode {default ok} ok_modes {default ok} fault_modes {default unknownFault} mode_transitions {default {}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default ok} recovery_modes {default {}}}}

set pirClass(input) {cfg_file input.cfg terminal_class input inputs {} outputs {} class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}} steady_state_power {default {}} steady_state_power_modes {default {}} mode_transitions {default {}} component_file {default {}} model_markers {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output.cfg terminal_class output inputs {} outputs {} class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}} steady_state_power {default {}} steady_state_power_modes {default {}} mode_transitions {default {}} component_file {default {}} model_markers {default {}}} nodeClassType terminal}

set pirClass(okMode) {cfg_file okMode.cfg mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(displayState) {cfg_file displayState.cfg attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(faultMode) {cfg_file faultMode.cfg mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {awillTypes}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {awillTypes}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
