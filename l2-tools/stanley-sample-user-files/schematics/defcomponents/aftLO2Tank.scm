global pirNodes
set pirNodes {49 1 2 4 6 8 10 12 14 16}
global pirNode
set pirNode(49) {edgesFrom {{} {} {}} edgesTo {{}} numArgsVars 0 argsValues {} attributes {?name.lO2 ?name.displayState} port_terminals {} output_terminals {?name.lO2Level ?name.ullageLine ?name.lO2EngineInlet} input_terminals ?name.lO2Line nodeInstanceName ?name nodeState nominal nodeStateBgColor gray90 nodeClassName aftLO2Tank numInputs 1 numOutputs 3 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {lO2FeedLine in} terminal_name ?name.lO2Line terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} outputs {out1 {type {lO2FeedLine out} terminal_name ?name.lO2EngineInlet terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown}} interfaceType public} out2 {type {ventLinePressure out} terminal_name ?name.ullageLine terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public} out3 {type {emptyValues out} terminal_name ?name.lO2Level terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 150 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName aftLO2Tank numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{// SOME GENERAL PROPERTIES OF LOX IN THE TANK
// during captive carry, there's nominally always LOX in the tank
lO2.level = notEmpty;
// we'll say that LOX temperature is within range when the tank
// is nominal
lO2.temperature.upperBound = belowThreshold;
lO2.temperature.lowerBound = aboveThreshold;


// SOME GENERAL PROPERTIES OF THE ENGINE INLET LINE
lO2EngineInlet.pressure.bleedRate = lO2.pressure.bleedRate;
lO2EngineInlet.temperature.lO2 = lO2.temperature;
lO2EngineInlet.flow = lO2.flow;


// SOME GENERAL PROPERTIES OF THE ULLAGE LINE
ullageLine = lO2.pressure;


// SOME GENERAL PROPERTIES OF THE LO2 LINE
lO2Line.flow = lO2.flow;
lO2Line.temperature.lO2 = lO2.temperature;
lO2Line.pressure.bleedRate = lO2.pressure.bleedRate;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.nominal nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 510 nodeY 290 labelX 502 labelY 265 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {lO2FeedLine out} terminal_name ?name.lO2Line terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.lO2Line nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 520 nodeY 200 labelX 491 labelY 175 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {lO2FeedLine in} terminal_name ?name.lO2EngineInlet terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.lO2EngineInlet nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 580 nodeY 410 labelX 545 labelY 385 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{if ( mode = nominal ) 
  displayState = ok;
else 
  displayState = unknown;}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 250 labelX 27 labelY 225 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {lO2properties out} terminal_name ?name.lO2 terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.lO2 nodeState {} nodeStateBgColor orange nodeClassName attribute fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 190 nodeY 250 labelX 179 labelY 225 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {ventLinePressure in} terminal_name ?name.ullageLine terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ullageLine nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 460 nodeY 410 labelX 437 labelY 385 window .master.canvas.?name.c.w16}

set pirNode(14) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {emptyValues in} terminal_name ?name.lO2Level terminal_label {} commandMonitorType {monitored unknown} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.lO2Level nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 520 nodeY 450 labelX 503 labelY 425 window .master.canvas.?name.c.w18}

set pirNode(16) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 660 nodeY 290 labelX 652 labelY 265 window .master.canvas.?name.c.w20}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {aftLO2Tank okMode input output displayState attribute faultMode}
global pirClass
set pirClass(aftLO2Tank) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} argTypes {default {}} documentation {default {}} input_terminals {default {{lO2FeedLine ?name.lO2Line {}}}} output_terminals {default {{lO2FeedLine ?name.lO2EngineInlet {}} {ventLinePressure ?name.ullageLine {}} {emptyValues ?name.lO2Level {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState {}} {lO2properties ?name.lO2 {}}}} mode {default nominal} ok_modes {default nominal} fault_modes {default unknownFault} mode_transitions {default {}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default nominal} recovery_modes {default {}}}}

set pirClass(okMode) {cfg_file okMode.cfg mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(input) {cfg_file input.cfg terminal_class input inputs {} outputs {} class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}} steady_state_power {default {}} steady_state_power_modes {default {}} mode_transitions {default {}} component_file {default {}} model_markers {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output.cfg terminal_class output inputs {} outputs {} class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}} steady_state_power {default {}} steady_state_power_modes {default {}} mode_transitions {default {}} component_file {default {}} model_markers {default {}}} nodeClassType terminal}

set pirClass(displayState) {cfg_file displayState.cfg attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(attribute) {cfg_file attribute.cfg attribute_class attribute class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(faultMode) {cfg_file faultMode.cfg mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {aftLO2Tank}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {aftLO2Tank}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
