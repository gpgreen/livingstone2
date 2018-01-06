global pirNodes
set pirNodes {91 1 2 4 6 8 10 12 14 16}
global pirNode
set pirNode(91) {edgesFrom {{} {}} edgesTo {{} {}} numArgsVars 0 argsValues {} attributes {?name.lO2 ?name.displayState} port_terminals {} output_terminals {?name.ventLine ?name.lO2Line} input_terminals {?name.ullageLine ?name.pressurizationLine} nodeInstanceName ?name nodeState nominal nodeStateBgColor gray90 nodeClassName forwardLO2Tank numInputs 2 numOutputs 2 fgColor black nodeGroupName root parentNodeGroupList root nodeClassType component inputs {in1 {type {pressurizationLine in} terminal_name ?name.pressurizationLine terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public} in2 {type {ventLinePressure in} terminal_name ?name.ullageLine terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} outputs {out1 {type {lO2FeedLine out} terminal_name ?name.lO2Line terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown}} interfaceType public} out2 {type {ventLine out} terminal_name ?name.ventLine terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} transitionModesToDraw {} nodeHasIconP 1 displayStatePropName ?name.displayState instanceLabel {} nodeX 100 nodeY 100 labelX 132 labelY 75 window .master.canvas.root.c.w2}

set pirNode(1) {nodeGroupName ?name edgesFrom {} edgesTo {} nodeInstanceName root_P4 nodeState parent-link nodeStateBgColor gray90 nodeClassName forwardLO2Tank numInputs 0 numOutputs 0 fgColor black nodeClassType module inputs {} outputs {} parentNodeGroupList {?name root} nodeX 5 nodeY 5 labelX -1 labelY -1 window .master.canvas.?name.c.w5 nodeHasIconP 0}

set pirNode(2) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 model {{// SOME GENERAL PROPERTIES OF THE LOX IN THE TANK
// during captive carry, there's nominally always LOX in the tank.
lO2.level = notEmpty;


// SOME GENERAL PROPERTIES OF THE VENT LINE
// the temperature near the ventLine is a mixture of GOX/GHE/LOX, and
// we'll assume it's behavior mirrors the behavior of the LOX temperature.
ventLine.temperature.tankMixture = lO2.temperature;
// pressure in the ventLine is the same as pressure in the tank
ventLine.pressure = lO2.pressure;


// SOME GENERAL PROPERTIES OF THE LO2 AND ULLAGE LINES
// the pressure is assumed evenly distributed throughout the tank,
// the temperature toward the aft is dominated by LOX temperature
ullageLine = lO2.pressure;
lO2Line.temperature.lO2 = lO2.temperature;
lO2Line.pressure.bleedRate = lO2.pressure.bleedRate;
lO2Line.flow = lO2.flow;


// SOME GENERAL PROPERTIES OF THE PRESSURIZATION LINE WHEN NOT PRESSURIZING
if (pressurizationLine.contents = tankMixture)
   // the pressurization line will have the same temperature and pressure
   // as the tank mixture
   pressurizationLine.temperature.tankMixture = lO2.temperature &
   // ...mapToPressurizationLinePressure(lO2.pressure)
   pressurizationLine.pressure.rg11.lowerBound = belowThreshold;


// WHEN THERE'S NO FLOW IN OR OUT OF THE TANK
if (pressurizationLine.contents = tankMixture &
               ventLine.flowOut = zero &
              lO2Line.flow.sign = zero)
   // with no flow in or out of the tank, the pressure will increase at
   // the boiloff rate
   lO2.pressure.boiloffRate.upperBound = belowThreshold &
   lO2.pressure.boiloffRate.lowerBound = aboveThreshold;


// WHEN THE TANK IS PRESSURIZING
if (pressurizationLine.contents = gHe & 
               ventLine.flowOut = zero &
              lO2Line.flow.sign = zero)
   // we'll say the tank temperature behavior mirrors the temperature of
   // the GHe flowing into the tank
   lO2.temperature = pressurizationLine.temperature.gHe &
   // the tank pressurizationRate mirrors the behavior of rg11 regulation
   lO2.pressure.pressurizationRate = pressurizationLine.pressure.rg11;


// WHEN THE TANK IS VENTING   
if (pressurizationLine.contents = tankMixture & 
               ventLine.flowOut = positive &
              lO2Line.flow.sign = zero)
   ventLine.pressure.ventingRate.upperBound = belowThreshold &
   ventLine.pressure.ventingRate.lowerBound = aboveThreshold;


// WHEN LOX IS BEING FED TO THE AFT TANK
//if (pressurizationLine.contents = tankMixture &
//               ventLine.flowOut = zero &
//              lO2Line.flow.sign = positive)
// nothing more than what's said earlier;}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.nominal nodeState {} nodeStateBgColor lightgreen nodeClassName okMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 540 nodeY 330 labelX 532 labelY 305 window .master.canvas.?name.c.w6}

set pirNode(4) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {pressurizationLine out} terminal_name ?name.pressurizationLine terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.pressurizationLine nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 490 nodeY 230 labelX 443 labelY 205 window .master.canvas.?name.c.w8}

set pirNode(6) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {lO2FeedLine in} terminal_name ?name.lO2Line terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.lO2Line nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 610 nodeY 450 labelX 593 labelY 425 window .master.canvas.?name.c.w10}

set pirNode(8) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {displayStateValues out} terminal_name ?name.displayState terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{if (mode = nominal)
  displayState = ok;
else
  displayState = unknown;}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.displayState nodeState {} nodeStateBgColor orange nodeClassName displayState fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 50 nodeY 250 labelX 27 labelY 225 window .master.canvas.?name.c.w12}

set pirNode(10) {edgesFrom {} edgesTo {{}} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {in1 {type {ventLine in} terminal_name ?name.ventLine terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} numInputs 1 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ventLine nodeState {} nodeStateBgColor gray90 nodeClassName output fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 500 nodeY 450 labelX 483 labelY 425 window .master.canvas.?name.c.w14}

set pirNode(12) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {lO2properties out} terminal_name ?name.lO2 terminal_label {}}} numOutputs 1 inputs {} numInputs 0 facts {{}} nodeDescription {} nodeClassType attribute nodeInstanceName ?name.lO2 nodeState {} nodeStateBgColor orange nodeClassName attribute fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 140 nodeY 250 labelX 141 labelY 228 window .master.canvas.?name.c.w16}

set pirNode(14) {edgesFrom {{}} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {out1 {type {ventLinePressure out} terminal_name ?name.ullageLine terminal_label {} commandMonitorType {monitored {unknown unknown unknown unknown unknown unknown unknown unknown unknown}} interfaceType public}} numOutputs 1 inputs {} numInputs 0 nodeDescription {} nodeClassType terminal nodeInstanceName ?name.ullageLine nodeState {} nodeStateBgColor gray90 nodeClassName input fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 inheritedCmdMonP 1 nodeX 600 nodeY 230 labelX 571 labelY 205 window .master.canvas.?name.c.w18}

set pirNode(16) {edgesFrom {} edgesTo {} nodeGroupName ?name numArgsVars 0 argsValues {} outputs {} numOutputs 0 inputs {} numInputs 0 probability unknownFaultRank model {{}} nodeDescription {} nodeClassType mode nodeInstanceName ?name.unknownFault nodeState {} nodeStateBgColor red1 nodeClassName faultMode fgColor black instanceLabel {} parentNodeGroupList {?name root} nodeHasIconP 1 nodeX 650 nodeY 330 labelX 642 labelY 305 window .master.canvas.?name.c.w20}

global pirEdges
set pirEdges {}
global pirEdge
global pirClasses
set pirClasses {forwardLO2Tank okMode input output displayState attribute faultMode}
global pirClass
set pirClass(forwardLO2Tank) {nodeClassType component inputs {} outputs {} class_variables {name_var {default ?name} args {default {}} argTypes {default {}} documentation {default {}} input_terminals {default {{pressurizationLine ?name.pressurizationLine {}} {ventLinePressure ?name.ullageLine {}}}} output_terminals {default {{lO2FeedLine ?name.lO2Line {}} {ventLine ?name.ventLine {}}}} port_terminals {default {}} attributes {default {{displayStateValues ?name.displayState {}} {lO2properties ?name.lO2 {}}}} mode {default nominal} ok_modes {default nominal} fault_modes {default unknownFault} mode_transitions {default {}} background_model {default {}} background_documentation {default {}} initially {default {}} initial_mode {default nominal} recovery_modes {default {}}}}

set pirClass(okMode) {cfg_file okMode.cfg mode_class okMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

set pirClass(input) {cfg_file input.cfg terminal_class input inputs {} outputs {} class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}} steady_state_power {default {}} steady_state_power_modes {default {}} mode_transitions {default {}} component_file {default {}} model_markers {default {}}} nodeClassType terminal}

set pirClass(output) {cfg_file output.cfg terminal_class output inputs {} outputs {} class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}} steady_state_power {default {}} steady_state_power_modes {default {}} mode_transitions {default {}} component_file {default {}} model_markers {default {}}} nodeClassType terminal}

set pirClass(displayState) {cfg_file displayState.cfg attribute_class displayState class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(attribute) {cfg_file attribute.cfg attribute_class attribute class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType attribute}

set pirClass(faultMode) {cfg_file faultMode.cfg mode_class faultMode class_variables {name_var {default {}} args {default {}} input_terminals {default { {nil}}} output_terminals {default { {nil}}} port_terminals {default { {nil}}} mode {default {}} ok_modes {default {}} fault_modes {default {}}} nodeClassType mode}

global g_NM_livingstoneDefcomponentFileName
set g_NM_livingstoneDefcomponentFileName {forwardLO2Tank}
global g_NM_livingstoneDefcomponentName
set g_NM_livingstoneDefcomponentName {forwardLO2Tank}
global g_NM_livingstoneDefcomponentNameVar
set g_NM_livingstoneDefcomponentNameVar {?name}
global g_NM_livingstoneDefcomponentArgList
set g_NM_livingstoneDefcomponentArgList {}
global g_NM_livingstoneDefcomponentArgTypeList
set g_NM_livingstoneDefcomponentArgTypeList {}
