global pirNodes
set pirNodes {53 1 2 4 6 8 10}
global pirNode
set pirNode(53) {edgesFrom {} edgesTo {{} {}} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals {} input_terminals {?name.pressureIn ?name.flowIn} nodeInstanceName ?name nodeState ok nodeStateBgColor gray90 nodeClassName loxDump numInputs 2 numOutputs 0 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {flowValues in} terminal_name ?name.flowIn terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public} in2 {type {pressureValues in} terminal_name ?name.pressureIn terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} outputs {} transitionModesToDraw {} nodeHasIconP 0 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX -1 labelY -1 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P3 nodeState parent-link nodeStateBgColor gray90 nodeClassName loxDump numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w4 nodeHasIconP 0}

set pirNode(2) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.ok nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 440 nodeY 290 labelX 447 labelY 265 window .master.canvas.?name.c.w5}

set pirNode(4) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {flowValues out} terminal_name ?name.flowIn terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.flowIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 330 nodeY 150 labelX 319 labelY 125 window .master.canvas.?name.c.w7}

set pirNode(6) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label displayState}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = ok)
  displayState = ok;
else
  displayState = unknown;}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 80 labelX 27 labelY 55 window .master.canvas.?name.c.w9}

set pirNode(8) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pressureValues out} terminal_name ?name.pressureIn terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pressureIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 500 nodeY 150 labelX 477 labelY 125 window .master.canvas.?name.c.w11}

set pirNode(10) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 560 nodeY 290 labelX 552 labelY 265 window .master.canvas.?name.c.w13}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {loxDump okMode input displayState faultMode}
global pirClass
set pirClass(loxDump) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} documentation {default {}} input_terminals {default {{flowValues ?name.flowIn {}} {pressureValues ?name.pressureIn {}}}} output_terminals {default {}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState displayState}}} mode {default ok} ok_modes {default ok} fault_modes {default unknownFault} mode_transitions {default {}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default ok} recovery_modes {default {}} argTypes {default {}}}}

set pirClass(okMode) {cfg_file okMode mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(input) {cfg_file input terminal_class input class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(displayState) {cfg_file displayState attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(faultMode) {cfg_file faultMode.cfg mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {loxDump}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {loxDump}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
