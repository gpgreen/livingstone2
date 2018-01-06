global pirNodes
set pirNodes {72 1 2 4 6 8 10 12 14}
global pirNode
set pirNode(72) {edgesFrom {{}} edgesTo {{}} numArgsVars 0 argsValues {} attributes ?name.displayState port_terminals {} output_terminals ?name.pressurizationLineOut input_terminals ?name.pressurizationLineIn nodeInstanceName ?name nodeState nominal nodeStateBgColor gray90 nodeClassName pressureRegulatorRG01 numInputs 1 numOutputs 1 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {pressurizationLine in} terminal_name ?name.pressurizationLineIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} outputs {out1 {type {pressurizationLine out} terminal_name ?name.pressurizationLineOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} transitionModesToDraw {} displayStatePropName ?name.displayState instanceLabel {} nodeHasIconP 1 nodeX 100 nodeY 100 labelX 100 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName pressureRegulatorRG01 numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{// nominal rg01 regulator behavior
pressurizationLineOut.pressure.rg01.upperBound = belowThreshold;
pressurizationLineOut.pressure.rg01.lowerBound = pressurizationLineIn.pressure.rg01.lowerBound;
// exploits knowledge that rg11.upperBound <= rg01.lowerBound
pressurizationLineOut.pressure.rg11 = pressurizationLineIn.pressure.rg11;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.nominal nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 230 nodeY 240 labelX 222 labelY 215 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label displayState}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = nominal)
  displayState = ok;
else {
if (mode = regulatingHigh |
    mode = regulatingLow)
  displayState = failed;
else
  displayState = unknown;
};}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel displayState parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 60 labelX 27 labelY 35 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 710 nodeY 240 labelX 705 labelY 215 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability likely model {{pressurizationLineOut.pressure = pressurizationLineIn.pressure;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.regulatingHigh nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 380 nodeY 240 labelX 351 labelY 215 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability likely model {{pressurizationLineOut.pressure.rg01.upperBound = belowThreshold;
pressurizationLineOut.pressure.rg01.lowerBound = belowThreshold;
// no claim possible about rg11 when regulating low;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.regulatingLow nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 540 nodeY 240 labelX 514 labelY 215 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pressurizationLine out} terminal_name ?name.pressurizationLineIn terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pressurizationLineIn nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 450 nodeY 70 labelX 397 labelY 45 window .master.canvas.?name.c.w16}

set pirNode(14) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {pressurizationLine in} terminal_name ?name.pressurizationLineOut terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pressurizationLineOut nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 470 nodeY 490 labelX 414 labelY 465 window .master.canvas.?name.c.w18}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {pressureRegulatorRG01 okMode displayState faultMode input output}
global pirClass
set pirClass(pressureRegulatorRG01) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} documentation {default {}} input_terminals {default {{pressurizationLine ?name.pressurizationLineIn {}}}} output_terminals {default {{pressurizationLine ?name.pressurizationLineOut {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState displayState}}} mode {default nominal} ok_modes {default nominal} fault_modes {default {unknownFault regulatingHigh regulatingLow}} mode_transitions {default {}} background_model {default {pressurizationLineOut.temperature = pressurizationLineIn.temperature;
pressurizationLineOut.contents = pressurizationLineIn.contents;}} background_documentation {default {}} initially {default {}} initial_mode {default nominal} recovery_modes {default {}} argTypes {default {}}}}

set pirClass(okMode) {cfg_file okMode.cfg mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(displayState) {cfg_file displayState.cfg attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(faultMode) {cfg_file faultMode mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(input) {cfg_file input.cfg terminal_class input class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output.cfg terminal_class output class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType terminal}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {pressureRegulatorRG01}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {pressureRegulatorRG01}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
