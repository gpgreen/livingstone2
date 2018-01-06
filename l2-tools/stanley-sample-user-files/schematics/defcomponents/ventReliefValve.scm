global pirNodes
set pirNodes {130 1 2 4 6 8 10 12 14 16 18}
global pirNode
set pirNode(130) {edgesFrom {{}} edgesTo {{} {}} numArgsVars 0 argsValues {} attributes {?name.displayState ?name.valvePosition} port_terminals {} output_terminals ?name.ventLineOut input_terminals {?name.pneumaticLineIn ?name.ventLineIn} nodeInstanceName ?name nodeState nominal nodeStateBgColor gray90 nodeClassName ventReliefValve numInputs 2 numOutputs 1 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {ventLine in} terminal_name ?name.ventLineIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public} in2 {type {thresholdValues in} terminal_name ?name.pneumaticLineIn terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} outputs {out1 {type {ventLineTemperature out} terminal_name ?name.ventLineOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 105 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName ventReliefValve numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

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
};}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 70 labelX 27 labelY 45 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {} edgesTo {} transitions {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{if (pneumaticLineIn = aboveThreshold)
   valvePosition = open;

if (pneumaticLineIn = belowThreshold)
   valvePosition = closed;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.nominal nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 270 nodeY 260 labelX 262 labelY 235 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {ventLine out} terminal_name ?name.ventLineIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ventLineIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 290 nodeY 90 labelX 267 labelY 65 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {thresholdValues out} terminal_name ?name.pneumaticLineIn terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pneumaticLineIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 410 nodeY 90 labelX 372 labelY 65 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {ventLineTemperature in} terminal_name ?name.ventLineOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ventLineOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 350 nodeY 440 labelX 324 labelY 415 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {openClosedValues out} terminal_name ?name.valvePosition terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{if (ventLineIn.pressure.pr02Crack = aboveThreshold)
  valvePosition = open;
else
  valvePosition = closed;}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.valvePosition nodeState {} nodeStateBgColor orange nodeClassName attribute fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 200 labelX 24 labelY 175 window .master.canvas.?name.c.w16}

set pirNode(14) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability lessLikely model {{valvePosition = open;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.stuckOpen nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 340 nodeY 260 labelX 326 labelY 235 window .master.canvas.?name.c.w18}

set pirNode(16) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability likely model {{valvePosition = closed;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.stuckClosed nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 420 nodeY 260 labelX 400 labelY 235 window .master.canvas.?name.c.w20}

set pirNode(18) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 530 nodeY 260 labelX 522 labelY 235 window .master.canvas.?name.c.w22}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {ventReliefValve displayState okMode input output attribute faultMode}
global pirClass
set pirClass(ventReliefValve) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} documentation {default {}} input_terminals {default {{ventLine ?name.ventLineIn {}} {thresholdValues ?name.pneumaticLineIn {}}}} output_terminals {default {{ventLineTemperature ?name.ventLineOut {}}}} port_terminals {default {}} attributes {default {{openClosedValues ?name.valvePosition {}} {displayStateValues ?name.displayState displayState}}} mode {default nominal} ok_modes {default nominal} fault_modes {default {stuckOpen stuckClosed unknownFault}} mode_transitions {default {}} background_model {default {if (valvePosition = closed) {
   ventLineOut.ambient.upperBound = belowThreshold &
   ventLineOut.ambient.lowerBound = aboveThreshold &
   ventLineIn.flowOut = zero;
}

if (valvePosition = open) {
   // This assumes there's mixture in the tank at higher pressure than
   // ambient, so that mixture is indeed venting when the valve is open.
   ventLineIn.flowOut = positive &
   ventLineOut.tankMixture = ventLineIn.temperature.tankMixture;
};}} background_documentation {default {}} initially {default {ventLineIn.pressure.pr02Crack = belowThreshold;}} initial_mode {default nominal} recovery_modes {default {}} argTypes {default {}}}}

set pirClass(displayState) {cfg_file displayState attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(okMode) {cfg_file okMode mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(input) {cfg_file input.cfg terminal_class input class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output.cfg terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(attribute) {cfg_file attribute attribute_class attribute class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(faultMode) {cfg_file faultMode mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {ventReliefValve}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {ventReliefValve}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
