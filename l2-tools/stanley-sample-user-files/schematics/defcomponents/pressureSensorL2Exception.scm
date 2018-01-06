global pirNodes
set pirNodes {66 1 2 4 6 8 10}
global pirNode
set pirNode(66) {edgesFrom {{}} edgesTo {{}} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals ?name.pressureReading input_terminals ?name.ambientPressure nodeInstanceName ?name nodeState ok nodeStateBgColor gray90 nodeClassName pressureSensorL2Exception numInputs 1 numOutputs 1 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {pressureValues in} terminal_name ?name.ambientPressure terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public}} outputs {out1 {type {pressureValues out} terminal_name ?name.pressureReading terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 0 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX -1 labelY -1 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P3 nodeState parent-link nodeStateBgColor gray90 nodeClassName pressureSensorL2Exception numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w4 nodeHasIconP 0}

set pirNode(2) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{ambientPressure = pressureReading;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.ok nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 340 nodeY 250 labelX 347 labelY 225 window .master.canvas.?name.c.w5}

set pirNode(4) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label displayState}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = unknown)
  displayState = unknown;
else {
if (pressureReading.rel = high)
  displayState = high;
else {
if (pressureReading.rel = nominal)
  displayState = nominal;
else {
if (pressureReading.rel = low)
  displayState = low;
}}};}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 50 labelX 27 labelY 25 window .master.canvas.?name.c.w7}

set pirNode(6) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 610 nodeY 250 labelX 605 labelY 225 window .master.canvas.?name.c.w9}

set pirNode(8) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pressureValues out} terminal_name ?name.ambientPressure terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ambientPressure nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 470 nodeY 140 labelX 432 labelY 115 window .master.canvas.?name.c.w11}

set pirNode(10) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pressureValues in} terminal_name ?name.pressureReading terminal_label {} commandMonitorType {monitored {unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pressureReading nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 470 nodeY 380 labelX 432 labelY 355 window .master.canvas.?name.c.w13}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {pressureSensorL2Exception okMode displayState faultMode input output}
global pirClass
set pirClass(pressureSensorL2Exception) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default ?context} documentation {default {Test->Scope->component->pressureSensorL2Exception
Test->Load & Go
results in Stanley user alert:
While processing Stanley command line request --
`refresh':
"propagate: Livingstone in inconsistent state"                                

and Skunkworks/Livingstone msgs:
LivingstoneCommandLine.command(refresh)
propagate: Livingstone in inconsistent state
>>asynchronousMsg(1, propagate: Livingstone in inconsistent state)}} input_terminals {default {{pressureValues ?name.ambientPressure {}}}} output_terminals {default {{pressureValues ?name.pressureReading {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState displayState}}} mode {default ok} ok_modes {default ok} fault_modes {default unknownFault} mode_transitions {default {}} background_model {default {}} background_documentation {default {}} initially {default {ambientPressure.rel = high;
pressureReading.rel = nominal;}} initial_mode {default ok} recovery_modes {default {}} argTypes {default contextValue}}}

set pirClass(okMode) {cfg_file okMode mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(displayState) {cfg_file displayState attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(faultMode) {cfg_file faultMode mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(input) {cfg_file input terminal_class input class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {pressureSensorL2Exception}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {pressureSensorL2Exception}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {?context}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {contextValue}
