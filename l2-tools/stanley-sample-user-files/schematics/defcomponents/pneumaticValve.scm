global pirNodes
set pirNodes {124 1 2 4 6 8 10 12 14 16 18}
global pirNode
set pirNode(124) {edgesFrom {{}} edgesTo {{} {}} numArgsVars 0 argsValues {} attributes {?name.valvePosition ?name.displayState} port_terminals {} output_terminals ?name.lO2FeedLineOut input_terminals {?name.pneumaticsLineIn ?name.lO2FeedLineIn} nodeInstanceName ?name nodeState nominal nodeStateBgColor gray90 nodeClassName pneumaticValve numInputs 2 numOutputs 1 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {lO2FeedLine in} terminal_name ?name.lO2FeedLineIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown}} interfaceType public} in2 {type {thresholdValues in} terminal_name ?name.pneumaticsLineIn terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} outputs {out1 {type {lO2FeedLine out} terminal_name ?name.lO2FeedLineOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 105 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName pneumaticValve numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label displayState}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = nominal) {
   if (valvePosition = open)
      displayState = open;
   if (valvePosition = closed)
      displayState = closed;
} else {
   if (mode = stuckOpen | mode = stuckClosed)
      displayState = failed;
   else
      displayState = unknown;
};}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 50 labelX 27 labelY 25 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability lessLikely model {{valvePosition = open;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.stuckOpen nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 560 nodeY 260 labelX 536 labelY 235 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {} edgesTo {} transitions {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{if (pneumaticsLineIn = aboveThreshold)
  valvePosition = open;
else
  valvePosition = closed;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.nominal nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 440 nodeY 260 labelX 432 labelY 235 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {openClosedValues out} terminal_name ?name.valvePosition terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.valvePosition nodeState {} nodeStateBgColor orange nodeClassName attribute fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 290 nodeY 260 labelX 264 labelY 235 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {lO2FeedLine out} terminal_name ?name.lO2FeedLineIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.lO2FeedLineIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 440 nodeY 70 labelX 414 labelY 45 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {lO2FeedLine in} terminal_name ?name.lO2FeedLineOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.lO2FeedLineOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 510 nodeY 380 labelX 481 labelY 355 window .master.canvas.?name.c.w16}

set pirNode(14) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {thresholdValues out} terminal_name ?name.pneumaticsLineIn terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pneumaticsLineIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 610 nodeY 70 labelX 569 labelY 45 window .master.canvas.?name.c.w18}

set pirNode(16) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability lessLikely model {{valvePosition = closed;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.stuckClosed nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 620 nodeY 260 labelX 600 labelY 235 window .master.canvas.?name.c.w20}

set pirNode(18) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 750 nodeY 260 labelX 742 labelY 235 window .master.canvas.?name.c.w22}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {pneumaticValve displayState faultMode okMode attribute input output}
global pirClass
set pirClass(pneumaticValve) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} documentation {default {}} input_terminals {default {{lO2FeedLine ?name.lO2FeedLineIn {}} {thresholdValues ?name.pneumaticsLineIn {}}}} output_terminals {default {{lO2FeedLine ?name.lO2FeedLineOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState displayState} {openClosedValues ?name.valvePosition {}}}} mode {default nominal} ok_modes {default nominal} fault_modes {default {stuckOpen stuckClosed unknownFault}} mode_transitions {default {}} background_model {default {if (valvePosition = open)
   lO2FeedLineOut = lO2FeedLineIn;
if (valvePosition = closed)
   lO2FeedLineIn.flow.sign = zero &
   lO2FeedLineOut.flow.sign = zero;}} background_documentation {default {}} initially {default {}} initial_mode {default nominal} recovery_modes {default {}} argTypes {default {}}}}

set pirClass(displayState) {cfg_file displayState attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(faultMode) {cfg_file faultMode mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(okMode) {cfg_file okMode mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(attribute) {cfg_file attribute attribute_class attribute class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(input) {cfg_file input terminal_class input class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {pneumaticValve}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {pneumaticValve}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
