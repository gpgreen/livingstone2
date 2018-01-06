global pirNodes
set pirNodes {22 1 2 4 6 8 10 12 14 16 18 20 27}
global pirNode
set pirNode(22) {edgesFrom {{} {} {} {}} edgesTo {{} {} {} {}} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals {?name.fuelPressureOut ?name.ullagePressureOut ?name.ullageVentOut ?name.fuelFlowOut} input_terminals {?name.ullagePressureIn ?name.ghePressureIn ?name.gheFlowIn ?name.ullageFlowIn} nodeInstanceName ?name nodeState ok nodeStateBgColor gray90 nodeClassName fwdLeftCompartment numInputs 4 numOutputs 4 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {flowValues in} terminal_name ?name.ullageFlowIn terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public} in2 {type {flowValues in} terminal_name ?name.gheFlowIn terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public} in3 {type {pressureValues in} terminal_name ?name.ghePressureIn terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public} in4 {type {pressureValues in} terminal_name ?name.ullagePressureIn terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} outputs {out1 {type {flowValues out} terminal_name ?name.fuelFlowOut terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public} out2 {type {flowValues out} terminal_name ?name.ullageVentOut terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public} out3 {type {pressureValues out} terminal_name ?name.ullagePressureOut terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public} out4 {type {pressureValues out} terminal_name ?name.fuelPressureOut terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 0 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX -1 labelY -1 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P3 nodeState parent-link nodeStateBgColor gray90 nodeClassName fwdLeftCompartment numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w4 nodeHasIconP 0}

set pirNode(2) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.ok nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 420 nodeY 260 labelX 427 labelY 235 window .master.canvas.?name.c.w5}

set pirNode(4) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {flowValues in} terminal_name ?name.fuelFlowOut terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.fuelFlowOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 320 nodeY 380 labelX 294 labelY 355 window .master.canvas.?name.c.w7}

set pirNode(6) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label displayState}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = ok)
  displayState = ok;
else
  displayState = unknown;}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 60 labelX 27 labelY 35 window .master.canvas.?name.c.w9}

set pirNode(8) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {flowValues out} terminal_name ?name.ullageFlowIn terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ullageFlowIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 530 nodeY 130 labelX 501 labelY 105 window .master.canvas.?name.c.w11}

set pirNode(10) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {flowValues in} terminal_name ?name.ullageVentOut terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ullageVentOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 530 nodeY 380 labelX 498 labelY 355 window .master.canvas.?name.c.w13}

set pirNode(12) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {flowValues out} terminal_name ?name.gheFlowIn terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.gheFlowIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 320 nodeY 130 labelX 300 labelY 105 window .master.canvas.?name.c.w15}

set pirNode(14) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 550 nodeY 260 labelX 545 labelY 235 window .master.canvas.?name.c.w17}

set pirNode(16) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pressureValues out} terminal_name ?name.ghePressureIn terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ghePressureIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 310 nodeY 180 labelX 278 labelY 155 window .master.canvas.?name.c.w19}

set pirNode(18) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pressureValues out} terminal_name ?name.ullagePressureIn terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ullagePressureIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 520 nodeY 180 labelX 479 labelY 155 window .master.canvas.?name.c.w21}

set pirNode(20) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pressureValues in} terminal_name ?name.ullagePressureOut terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ullagePressureOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 520 nodeY 420 labelX 476 labelY 395 window .master.canvas.?name.c.w23}

set pirNode(27) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pressureValues in} terminal_name ?name.fuelPressureOut terminal_label {} commandMonitorType {monitored {noCommand noCommand}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.fuelPressureOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 310 nodeY 420 labelX 272 labelY 395 window .master.canvas.?name.c.w25}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {fwdLeftCompartment okMode output displayState input faultMode}
global pirClass
set pirClass(fwdLeftCompartment) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} documentation {default {}} input_terminals {default {{flowValues ?name.ullageFlowIn {}} {flowValues ?name.gheFlowIn {}} {pressureValues ?name.ghePressureIn {}} {pressureValues ?name.ullagePressureIn {}}}} output_terminals {default {{flowValues ?name.fuelFlowOut {}} {flowValues ?name.ullageVentOut {}} {pressureValues ?name.ullagePressureOut {}} {pressureValues ?name.fuelPressureOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState displayState}}} mode {default ok} ok_modes {default ok} fault_modes {default unknownFault} mode_transitions {default {}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default ok} recovery_modes {default {}} argTypes {default {}}}}

set pirClass(okMode) {cfg_file okMode mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(output) {cfg_file output terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(displayState) {cfg_file displayState attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(input) {cfg_file input terminal_class input class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(faultMode) {cfg_file faultMode mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {fwdLeftCompartment}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {fwdLeftCompartment}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
